##　卸载脚本
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
PROJECT_DIR=$(dirname ${BASE_DIR})

. "${BASE_DIR}/utils.sh"

function remove_rackshift() {
  echo -e "$(gettext 'Make sure you have a backup of data, this operation is not reversible')! \n"
  VOLUME_DIR=$(get_config VOLUME_DIR)
  images=$(get_images)
  confirm="n"
  read_from_input confirm "$(gettext 'Are you clean up RackShift files')?" "y/n" "${confirm}"
  if [[ "${confirm}" == "y" ]]; then
    if [[ -f "${CONFIG_FILE}" ]]; then
      cd "${PROJECT_DIR}" || exit 1
      bash ./rsctl.sh down
      sleep 2s
      echo
      echo -e "$(gettext 'Cleaning up') ${VOLUME_DIR}"
      rm -rf "${VOLUME_DIR}"
      echo -e "$(gettext 'Cleaning up') ${CONFIG_DIR}"
      rm -rf "${CONFIG_DIR}"
      echo_done
    fi
  fi
  echo
  confirm="n"
  read_from_input confirm "$(gettext 'Do you need to clean up the Docker image')?" "y/n" "${confirm}"
  if [[ "${confirm}" == "y" ]]; then
    for image in ${images}; do
      docker rmi "${image}"
    done
  fi
  echo_green "$(gettext 'Cleanup complete')!"
}

function main() {
  echo_yellow "\n>>> $(gettext 'Uninstall RackShift')"
  remove_rackshift
}

main
