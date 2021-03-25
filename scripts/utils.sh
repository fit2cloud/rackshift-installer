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
  command -v ifconfig &>/dev/null
  if [[ "$?" == "0" ]]; then
    cmd=ifconfig
  else
    cmd="ip a"
  fi
  sh -c "${cmd}" | tail -10 | base64 | head -c ${len}
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
  docker run -it --rm rackshift/mysql:5.7.31 mysql -h${host} -P${port} -u${user} -p${password} ${db} -e "${command}" 2>/dev/null
}

function get_images() {
  scope="all"
  if [[ ! -z "$1" ]]; then
    scope="$1"
  fi
  images=(
    "rackshift/mysql:5.7.31"
    "rackshift/mongo:latest"
    "rackshift/rabbitmq:management"
    "rackshift/isc-dhcp-server:latest"
    "rackshift/kfox1111/ipmitool:latest"
    "rackshift/kciepluc/racadm-docker:latest"
    "rackshift/rackshift-files:${VERSION}"
    "rackshift/on-dhcp-proxy:${VERSION}"
    "rackshift/on-http:${VERSION}"
    "rackshift/on-syslog:${VERSION}"
    "rackshift/rackshift-taskgraph:${VERSION}"
    "rackshift/on-tftp:${VERSION}"
    "rackshift/rackshift:${VERSION}"
    "rackshift/rackshift-proxy:${VERSION}"
    "rackshift/rackshift-plugins:${VERSION}"
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

function is_running() {
  ps axu | grep -v grep | grep $1 &>/dev/null
  if [[ "$?" == "0" ]]; then
    echo 1
  else
    echo 0
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
