#!/usr/bin/env bash
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
# shellcheck source=./util.sh
. "${BASE_DIR}/utils.sh"
# shellcheck source=./2_install_docker.sh
. "${BASE_DIR}/2_install_docker.sh"

target=$1

function update_proc_if_need() {
  if [[ ! -f ./docker/dockerd ]]; then
    confirm="n"
    read_from_input confirm "$(gettext 'Do you need to update') Docker?" "y/n" "${confirm}"
    if [[ "${confirm}" == "y" ]]; then
      install_docker
      install_compose
    fi
    echo_done
  else
    # 针对离线包不做判断，直接更新
    install_docker
    install_compose
  fi
}

function backup_db() {
  if [[ "${SKIP_BACKUP_DB}" != "1" ]]; then
    if ! bash "${SCRIPT_DIR}/5_db_backup.sh"; then
      confirm="n"
      read_from_input confirm "$(gettext 'Failed to backup the database. Continue to upgrade')?" "y/n" "${confirm}"
      if [[ "${confirm}" == "n" ]]; then
        exit 1
      fi
    fi
  else
    echo "SKIP_BACKUP_DB=${SKIP_BACKUP_DB}, $(gettext 'Skip database backup')"
  fi
}

function main() {
  confirm="n"
  to_version="${VERSION}"
  if [[ -n "${target}" ]]; then
    to_version="${target}"
  fi

  read_from_input confirm "$(gettext 'Are you sure you want to update the current version to') ${to_version} ?" "y/n" "${confirm}"
  if [[ "${confirm}" != "y" || -z "${to_version}" ]]; then
    exit 3
  fi

  if [[ "${to_version}" && "${to_version}" != "${VERSION}" ]]; then
    sed -i "s@VERSION=.*@VERSION=${to_version}@g" "${PROJECT_DIR}/static.env"
    export VERSION=${to_version}
  fi

  echo_yellow "\n$(gettext 'Check program file changes')"
  update_proc_if_need || (echo_failed; exit  4)

  echo_yellow "\n$(gettext 'Upgrade Docker image')"
  bash "${SCRIPT_DIR}/3_load_images.sh" && echo_done || (echo_failed; exit  5)

  echo_yellow "\n$(gettext 'Backup database')"
  backup_db || exit 2

  echo_yellow "\n$(gettext 'Upgrade successfully. You can now restart the program')"
  echo "./rsctl.sh restart"
  echo -e "\n\n"
}

if [[ "$0" == "${BASH_SOURCE[0]}" ]]; then
  main
fi
