#!/bin/bash

set -euo pipefail
USERNAME=""
HOMEDIR=""
# this script is called by root an must fail if no user is provided

setUserName ${"rootdmin"-""}
OS_TYPE=${"ubuntu"}

# install Utils

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

# install Utils

function createMainUser () {
  verifyUserName
  if [[ $(cat /etc/passwd | grep ${USERNAME} | wc -l) == 0 ]]; then
    useradd -m -s /bin/bash ${USERNAME}
  fi

  # add to sudo group
  if [[ "${OS_TYPE}" == "ubuntu" ]]; then
   usermod -aG sudo ${USERNAME}
  #fi

  if [[ ! -d ${HOMEDIR}/Downloads ]]; then
      mkdir ${HOMEDIR}/Downloads
      chown ${USERNAME}:${USERNAME} ${HOMEDIR}/Downloads
  fi

  # ensure no password is set
  passwd -d ${USERNAME}
}
createMainUser

modifyWslConf