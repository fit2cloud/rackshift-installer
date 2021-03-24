#!/bin/bash

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=scripts/utils.sh
. "${PROJECT_DIR}/scripts/utils.sh"

action=${1-}
target=${2-}
args=("$@")

function check_config_file() {
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    echo "$(gettext 'Configuration file not found'): ${CONFIG_FILE}"
    echo "$(gettext 'Please install it first')"
    return 3
  fi
  if [[ ! -f .env ]]; then
    ln -s "${CONFIG_FILE}" .env
  fi
}

function pre_check() {
  check_config_file || return 3
}

function usage() {
  echo "RackShift 安装部署脚本"
  echo
  echo "Usage: "
  echo "  rsctl [COMMAND] [ARGS...]"
  echo "  rsctl --help"
  echo
  echo "Installation Commands: "
  echo "  status     检查 RackShift 服务"
  echo "  reconfig   重设 RackShift 服务"
  echo "  upgrade    升级 RackShift 版本"
  echo
  echo "Management Commands: "
  echo "  start      启动 RackShift 服务"
  echo "  stop       停止 RackShift 服务"
  echo "  down       下线 RackShift 服务"
  echo "  restart    重启 RackShift 服务"
  echo "  reload     重载 RackShift 服务"
  echo "  uninstall  卸载 RackShift 服务"
  echo
  echo "More Commands: "
  echo "  version    查看 RackShift 版本"
}

function service_to_docker_name() {
  service=$1
  if [[ "${service:0:3}" != "rs" ]]; then
    service=rs_${service}
  fi
  echo "${service}"
}

EXE=""

function start() {
  ${EXE} up -d
}

function stop() {
  ${EXE} stop
}

function down() {
  ${EXE} down
}

function restart() {
  stop
  echo -e "\n"
  start
}

function check_update() {
  current_version="${VERSION}"
  latest_version=$(get_latest_version)
  if [[ "${current_version}" == "${latest_version}" ]]; then
    echo "$(gettext 'The current version is up to date')"
    return
  fi
  echo "$(gettext 'The latest version is'): ${latest_version}"
  echo "$(gettext 'The current version is'): ${current_version}"
  echo
  bash "${SCRIPT_DIR}/7_upgrade.sh" "${latest_version}"
}

function main() {
  if [[ "${action}" == "help" || "${action}" == "h" || "${action}" == "-h" || "${action}" == "--help" ]]; then
    echo ""
  elif [[ "${action}" == "install" || "${action}" == "reconfig" ]]; then
    echo ""
  else
    pre_check || return 3
    EXE=$(get_docker_compose_cmd_line)
  fi
  case "${action}" in
    install)
      bash "${SCRIPT_DIR}/4_install_rackshift.sh"
      ;;
    upgrade)
      bash "${SCRIPT_DIR}/7_upgrade.sh" "$target"
      ;;
    check_update)
      check_update
      ;;
    reconfig)
      if [[ -f "${CONFIG_DIR}/rackhd/monorail/config.json" ]]; then
        mv ${CONFIG_DIR}/rackhd/monorail/config.json ${CONFIG_DIR}/rackhd/monorail/config.json.bak-$(date +%F_%T)
      fi
      if [[ -f "${config_dir}/rackshift.properties" ]]; then
        mv ${config_dir}/rackshift.properties ${config_dir}/rackshift.properties.bak-$(date +%F_%T)
      fi
      bash "${SCRIPT_DIR}/1_config_rackshift.sh"

      mysql_host=$(get_config DB_HOST)
      mysql_port=$(get_config DB_PORT)
      mysql_user=$(get_config DB_USER)
      mysql_pass=$(get_config DB_PASSWORD)
      mysql_db=$(get_config DB_NAME)
      rackshift_ip=$(get_config RACKSHIFT_IP)
      command="update endpoint set ip='${rackshift_ip}' where type='main_endpoint';"
      docker run -it --rm rackshift/mysql:5.7.31 mysql -h${mysql_host} -P${mysql_port} -u${mysql_user} -p${mysql_pass} ${mysql_db} -e "${command}" 2>/dev/null
      if [ $? -eq 0 ]; then
        echo_yellow "\n$(gettext 'Reconfig successfully. You can now restart the program')"
        echo "./rsctl.sh restart"
        echo -e "\n\n"
      else
        log_error "重置失败, 请重试或者检查数据库是否正常. "
        exit 1
      fi
      ;;
    start)
      start
      ;;
    restart)
      restart
      ;;
    stop)
      stop
      ;;
    close)
      close
      ;;
    status)
      ${EXE} ps
      ;;
    down)
      if [[ -z "${target}" ]]; then
        ${EXE} down -v
      else
        ${EXE} stop "${target}" && ${EXE} rm -f "${target}"
      fi
      ;;
    uninstall)
      bash "${SCRIPT_DIR}/8_uninstall.sh"
      ;;
    backup_db)
      bash "${SCRIPT_DIR}/5_db_backup.sh"
      ;;
    restore_db)
      bash "${SCRIPT_DIR}/6_db_restore.sh" "$target"
      ;;
    load_image)
      bash "${SCRIPT_DIR}/3_load_images.sh"
      ;;
    cmd)
      echo "${EXE}"
      ;;
    tail)
      if [[ -z "${target}" ]]; then
        ${EXE} logs --tail 100 -f
      else
        docker_name=$(service_to_docker_name "${target}")
        docker logs -f "${docker_name}" --tail 100
      fi
      ;;
    show_services)
      get_docker_compose_services
      ;;
    raw)
      ${EXE} "${args[@]:1}"
      ;;
    help)
      usage
      ;;
    --help)
      usage
      ;;
    -h)
      usage
      ;;
    *)
      echo "No such command: ${action}"
      usage
      ;;
    esac
}

main "$@"
