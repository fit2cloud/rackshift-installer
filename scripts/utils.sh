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
  docker run -it --rm registry.cn-qingdao.aliyuncs.com/x-lab/mysql:5.7.31 mysql -h${host} -P${port} -u${user} -p${password} ${db} -e "${command}" 2>/dev/null
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

function get_docker_compose_cmd_line() {
  ignore_db="$1"
  cmd="docker-compose -f ./compose/docker-compose-app.yml "
  use_external_mysql=$(get_config USE_EXTERNAL_MYSQL)
  if [[ "${use_external_mysql}" != "1" && "${ignore_db}" != "ignore_db" ]]; then
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
  if command -v firewall-cmd > /dev/null; then
    firewall-cmd --state > /dev/null 2>&1
    if [[ "$?" == "0" ]]; then
      http_port=$(get_config HTTP_PORT)
      if [[ ! "$(firewall-cmd --list-ports | grep ${http_port}/tcp)" ]]; then
        firewall-cmd --zone=public --add-port=${http_port}/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 8080/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=8080/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 8083/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=8083/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 8443/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=8443/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 9080/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=9080/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 9090/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=9090/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 9030/tcp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=9030/tcp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 4011/udp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=4011/udp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 67/udp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=67/udp
        flag=1
      fi
      if [[ ! "$(firewall-cmd --list-ports | grep 69/udp)" ]]; then
        firewall-cmd --permanent --zone=public --add-port=69/udp
        flag=1
      fi
      if command -v dnf > /dev/null; then
        if [[ ! "$(firewall-cmd --list-all | grep 'masquerade: yes')" ]]; then
          firewall-cmd --permanent --add-masquerade
          flag=1
        fi
      fi
      if [[ "$flag" ]]; then
        firewall-cmd --reload
      fi
    fi
  fi
}

function prepare_config() {
  cwd=$(pwd)
  cd "${PROJECT_DIR}" || exit 1

  echo_yellow "1. $(gettext 'Check Configuration File')"
  echo "$(gettext 'Path to Configuration file'): ${CONFIG_DIR}"
  if [[ ! -d "${CONFIG_DIR}" ]]; then
    mkdir -p ${CONFIG_DIR}
    cp config-example.txt "${CONFIG_FILE}"
  fi
  if [[ ! -f "${CONFIG_FILE}" ]]; then
    cp config-example.txt "${CONFIG_FILE}"
  else
    echo -e "${CONFIG_FILE}  [\033[32m √ \033[0m]"
  fi
  if [[ ! -f .env ]]; then
    ln -s "${CONFIG_FILE}" .env
  fi
  if [[ ! -f "./compose/.env" ]]; then
    ln -s "${CONFIG_FILE}" ./compose/.env
  fi
  echo_done

  backup_dir="${CONFIG_DIR}/backup"
  if [[ ! -d "${backup_dir}" ]]; then
    mkdir -p "${backup_dir}"
  fi
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

function docker_network_check() {
  if [[ ! "$(docker network ls | grep rs_default)" ]]; then
    docker network create rs_default
  fi
}

function set_current_version(){
  current_version=$(get_config CURRENT_VERSION)
  if [ "${current_version}" != "${VERSION}" ]; then
    set_config CURRENT_VERSION "${VERSION}"
  fi
}
