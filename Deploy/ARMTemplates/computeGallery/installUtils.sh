#!/bin/bash

set -euo pipefail
DIR_INSTALL_UTILS=$(realpath $( dirname ${BASH_SOURCE[0]:-$0} ) )
USERNAME=""
HOMEDIR=""

setUserName () {
  USERNAME=${1-""}
  verifyUserName
}

verifyUserName () {
  if [[ ${USERNAME} == "" ]]; then
    echo "Please pass a user name"
    exit 1
  elif [[ ${USERNAME} == "root" ]]; then
    HOMEDIR="/root"
  else
    HOMEDIR="/home/${USERNAME}"
  fi
}

modifyWslConf () {
  verifyUserName
  sudo touch /etc/wsl.conf
  sudo echo "[user]" >> /etc/wsl.conf
  sudo echo "default=${USERNAME}" >> /etc/wsl.conf
}