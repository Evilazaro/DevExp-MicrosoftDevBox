#!/bin/bash

set -euo pipefail

scriptDir=$(realpath $(dirname $0))
# Source the installUtils.sh script. The "." is equivalent to "source" command.
. ${scriptDir}/installUtils.sh

userName=${1:-""}
osType=${2:-"ubuntu"}

verifyUserNameValidity() {
  if [[ -z "${userName}" ]]; then
    echo "Error: User name is not provided."
    exit 1
  fi
}

createMainUser() {
  verifyUserNameValidity

  if ! id "${userName}" &>/dev/null; then
    userAdd -m -s /bin/bash ${userName}
  fi

  addToSudoGroupIfUbuntu

  createDownloadsDirectory

  # Ensure no password is set
  passwd -d ${userName}
}

addToSudoGroupIfUbuntu() {
  if [[ "${osType}" == "ubuntu" ]]; then
    usermod -aG sudo ${userName}
  fi
}

createDownloadsDirectory() {
  homeDir=$(eval echo ~${userName})

  if [[ ! -d ${homeDir}/Downloads ]]; then
    mkdir ${homeDir}/Downloads
    chown ${userName}:${userName} ${homeDir}/Downloads
  fi
}

createMainUser
modifyWslConf
