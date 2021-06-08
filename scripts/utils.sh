#!/usr/bin/env bash

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# shellcheck source=./const.sh
. "${BASE_DIR}/const.sh"

function is_confirm() {
  read -r confirmed
  if [[ "${confirmed}" == "y" || "${confirmed}" == "Y" || ${confirmed} == "" ]]; then
    return 0
  else
    return 1
  fi
}

function random_str() {
  len=$1
  if [[ -z ${len} ]]; then
    len=16
  fi
  command -v dmidecode &>/dev/null
  uuid=None
  if [[ "$?" == "0" ]]; then
    uuid=$(dmidecode -t 1 | grep UUID | awk '{print $2}' | base64 | head -c ${len})
  fi
  if [[ "$(echo $uuid | wc -L)" == "${len}" ]]; then
    echo ${uuid}
  else
    cat /dev/urandom | tr -dc A-Za-z0-9 | head -c ${len}; echo
  fi
}

function has_config() {
  key=$1
  cwd=$(pwd)
  grep "^${key}=" "${CONFIG_FILE}" &>/dev/null

  if [[ "$?" == "0" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

function get_config() {
  cwd=$(pwd)
  key=$1
  value=$(grep "^${key}=" "${CONFIG_FILE}" | awk -F= '{ print $2 }')
  echo "${value}"
}

function set_config() {
  key=$1
  value=$2

  has=$(has_config "${key}")
  if [[ ${has} == "0" ]]; then
    echo "${key}=${value}" >>"${CONFIG_FILE}"
    return
  fi

  origin_value=$(get_config "${key}")
  if [[ "${value}" == "${origin_value}" ]]; then
    return
  fi

  if [[ "${OS}" == 'Darwin' ]]; then
    sed -i '' "s,^${key}=.*$,${key}=${value},g" "${CONFIG_FILE}"
  else
    sed -i "s,^${key}=.*$,${key}=${value},g" "${CONFIG_FILE}"
  fi
}

function test_mysql_connect() {
  host=$1
  port=$2
  user=$3
  password=$4
  db=$5
  command="CREATE TABLE IF NOT EXISTS test(id INT); DROP TABLE test;"
  docker run -it --rm x-lab/mysql:5.7.31 mysql -h${host} -P${port} -u${user} -p${password} ${db} -e "${command}" 2>/dev/null
}

function get_images() {
  scope="all"
  if [[ ! -z "$1" ]]; then
    scope="$1"
  fi
  images=(
    "x-lab/mysql:5.7.31"
    "x-lab/mongo:latest"
    "x-lab/rabbitmq:management"
    "x-lab/isc-dhcp-server:latest"
    "x-lab/ipmitool:latest"
    "x-lab/racadm-docker:latest"
    "x-lab/rackshift-files:v1.0.0"
    "x-lab/on-dhcp-proxy:v1.0.0"
    "x-lab/on-http:v1.0.0"
    "x-lab/on-syslog:v1.0.0"
    "x-lab/rackshift-taskgraph:v1.0.0"
    "x-lab/on-tftp:v1.0.0"
    "x-lab/rackshift:${VERSION}"
    "x-lab/rackshift-proxy:v1.0.0"
    "x-lab/rackshift-plugins:v1.0.0"
  )
  for image in "${images[@]}"; do
    echo "${image}"
  done
}

function read_from_input() {
  var=$1
  msg=$2
  choices=$3
  default=$4
  if [[ ! -z "${choices}" ]]; then
    msg="${msg} (${choices}) "
  fi
  if [[ -z "${default}" ]]; then
    msg="${msg} ($(gettext 'no default'))"
  else
    msg="${msg} ($(gettext 'default') ${default})"
  fi
  echo -n "${msg}: "
  read input
  if [[ -z "${input}" && ! -z "${default}" ]]; then
    export ${var}="${default}"
  else
    export ${var}="${input}"
  fi
}

function get_file_md5() {
  file_path=$1
  if [[ -f "${file_path}" ]]; then
    if [[ "${OS}" == "Darwin" ]]; then
      md5 "${file_path}" | awk -F= '{ print $2 }'
    else
      md5sum "${file_path}" | awk '{ print $1 }'
    fi
  fi
}

function check_md5() {
  file=$1
  md5_should=$2

  md5=$(get_file_md5 "${file}")
  if [[ "${md5}" == "${md5_should}" ]]; then
    echo "1"
  else
    echo "0"
  fi
}

function echo_red() {
  echo -e "\033[1;31m$1\033[0m"
}

function echo_green() {
  echo -e "\033[1;32m$1\033[0m"
}

function echo_yellow() {
  echo -e "\033[1;33m$1\033[0m"
}

function echo_done() {
  sleep 0.5
  echo "$(gettext 'complete')"
}

function echo_failed() {
  echo_red "$(gettext 'fail')"
}

function log_success() {
  echo_green "[SUCCESS] $1"
}

function log_warn() {
  echo_yellow "[WARN] $1"
}

function log_error() {
  echo_red "[ERROR] $1"
}

function get_docker_compose_services() {
  ignore_db="$1"
  services="mongo rabbitmq dhcp-server files dhcp-proxy http syslog task tftp core proxy plugins ipmitool racadm"
  use_external_mysql=$(get_config USE_EXTERNAL_MYSQL)
  if [[ "${use_external_mysql}" != "1" && "${ignore_db}" != "ignore_db" ]]; then
    services+=" mysql"
  fi
  echo "${services}"
}

function get_docker_compose_cmd_line() {
  ignore_db="$1"
  cmd="docker-compose -f ./compose/docker-compose-app.yml "
  services=$(get_docker_compose_services "$ignore_db")
  if [[ "${services}" =~ mysql ]]; then
    cmd="${cmd} -f ./compose/docker-compose-mysql.yml"
  fi
  echo "${cmd}"
}

function install_required_pkg() {
  required_pkg=$1
  if command -v dnf > /dev/null; then
    if [ "$required_pkg" == "python" ]; then
      dnf -q -y install python2
      ln -s /usr/bin/python2 /usr/bin/python
    else
      dnf -q -y install $required_pkg
    fi
  elif command -v yum > /dev/null; then
    yum -q -y install $required_pkg
  elif command -v apt > /dev/null; then
    apt-get -qq -y install $required_pkg
  elif command -v zypper > /dev/null; then
    zypper -q -n install $required_pkg
  elif command -v apk > /dev/null; then
    apk add -q $required_pkg
  else
    echo_red "$(gettext 'Please install it first') $required_pkg"
    exit 1
  fi
}

function prepare_online_install_required_pkg() {
  for i in curl wget python zip; do
    command -v $i >/dev/null || install_required_pkg $i
  done
}

function prepare_set_redhat_firewalld() {
  if [[ -f "/etc/redhat-release" ]]; then
    if [[ "$(firewall-cmd --state)" == "running" ]]; then
      if command -v dnf > /dev/null; then
        if [[ ! "$(firewall-cmd --list-all | grep 'masquerade: yes')" ]]; then
          firewall-cmd --permanent --add-masquerade
          firewall-cmd --reload
        fi
      fi
    fi
  fi
}

function prepare_config() {
  cwd=$(pwd)
  cd "${PROJECT_DIR}" || exit

  config_dir=$(dirname "${CONFIG_FILE}")
  echo_yellow "1. $(gettext 'Check Configuration File')"
  echo "$(gettext 'Path to Configuration file'): ${config_dir}"
  if [[ ! -d ${config_dir} ]]; then
    mkdir -p ${config_dir}
    cp config-example.txt "${CONFIG_FILE}"
  fi
  if [[ ! -f ${CONFIG_FILE} ]]; then
    cp config-example.txt "${CONFIG_FILE}"
  else
    echo -e "${CONFIG_FILE}  [\033[32m √ \033[0m]"
  fi
  if [[ ! -f .env ]]; then
    ln -s "${CONFIG_FILE}" .env
  if [[ ! -f "./compose/.env" ]]; then
    ln -s "${CONFIG_FILE}" ./compose/.env
  fi
  if [[ ! -f "${config_dir}/rackshift.properties" ]]; then
    cp config_init/rackshift.properties ${config_dir}
  else
    echo -e "${config_dir}/rackshift.properties  [\033[32m √ \033[0m]"
  fi
  if [[ ! -d "${config_dir}/rackshift" ]]; then
    cp -R config_init/rackhd ${config_dir}
  fi
  if [[ ! -d "${config_dir}/mysql" ]]; then
    cp -R config_init/mysql ${config_dir}
  fi
  for file in $(ls config_init/mysql); do
    if [[ ! -f "${config_dir}/mysql/${file}" ]]; then
      cp config_init/mysql/${file} ${config_dir}/mysql/
    else
      echo -e "${config_dir}/mysql/${file}  [\033[32m √ \033[0m]"
    fi
  done
  if [[ ! -f "${config_dir}/rackhd/monorail/config.json" ]]; then
    cp config_init/rackhd/monorail/config.json.bak ${config_dir}/rackhd/monorail/config.json
  else
    echo -e "${config_dir}/rackhd/monorail/config.json  [\033[32m √ \033[0m]"
  fi
  if [ -d plugins ]; then
    \cp -rf ../plugins/* ${config_dir}
  fi
  echo_done

  backup_dir="${config_dir}/backup"
  mkdir -p "${backup_dir}"
  now=$(date +'%Y-%m-%d_%H-%M-%S')
  backup_config_file="${backup_dir}/config.txt.${now}"
  echo_yellow "\n2. $(gettext 'Backup Configuration File')"
  cp "${CONFIG_FILE}" "${backup_config_file}"
  echo "$(gettext 'Back up to') ${backup_config_file}"
  echo_done
}

function echo_logo() {
  cat << "EOF"

  ██████╗   █████╗   ██████╗ ██╗  ██╗ ███████╗ ██╗  ██╗ ██╗ ███████╗ ████████╗
  ██╔══██╗ ██╔══██╗ ██╔════╝ ██║ ██╔╝ ██╔════╝ ██║  ██║ ██║ ██╔════╝ ╚══██╔══╝
  ██████╔╝ ███████║ ██║      █████╔╝  ███████╗ ███████║ ██║ █████╗      ██║
  ██╔══██╗ ██╔══██║ ██║      ██╔═██╗  ╚════██║ ██╔══██║ ██║ ██╔══╝      ██║
  ██║  ██║ ██║  ██║ ╚██████╗ ██║  ██╗ ███████║ ██║  ██║ ██║ ██║         ██║
  ╚═╝  ╚═╝ ╚═╝  ╚═╝  ╚═════╝ ╚═╝  ╚═╝ ╚══════╝ ╚═╝  ╚═╝ ╚═╝ ╚═╝         ╚═╝

EOF

  echo -e "\t\t\t\t\t\t\t   Version: \033[33m $VERSION \033[0m \n"
}

function get_latest_version() {
  curl -s 'https://api.github.com/repos/rackshift/rackshift/releases/latest' |
    grep "tag_name" | head -n 1 | awk -F ":" '{print $2}' |
    sed 's/\"//g;s/,//g;s/ //g'
}

function image_has_prefix() {
  if [[ $1 =~ registry.* ]]; then
    echo "1"
  else
    echo "0"
  fi
}

function upgrade_config() {
  # 如果配置文件有更新, 则添加到新的配置文件
  cwd=$(pwd)
  cd "${PROJECT_DIR}" || exit

  config_dir=$(dirname "${CONFIG_FILE}")
  cp -rf config_init/rackhd/conf/version ${config_dir}/rackhd/conf/version
}
