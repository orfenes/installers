#!/bin/bash

##################
# --- common --- #
##################

GRAY='\033[0;36m'
GREEN='\033[0;32m'
NO_COLOR='\033[1;0m'
RED='\033[1;31m'
YELLOW='\033[1;33m'

##################
# --- config --- #
##################

JOB_NAME='SSH Key#upload'

#####################
# --- functions --- #
#####################

ask() {
  read -p 'Local key path (~/.ssh/id_rsa): ' KEY_PATH

  [ "${KEY_PATH}" == '' ] && KEY_PATH=~/.ssh/id_rsa

  read -p 'Upload private key? (Y/n): ' PRIVATE

  if [[ "${PRIVATE}" == '' || "${PRIVATE}" == 'y' || "${PRIVATE}" == 'Y' ]]; then
    PRIVATE='true'
  fi

  read -p 'Upload public key? (Y/n): ' PUBLIC

  if [[ "${PUBLIC}" == '' || "${PUBLIC}" == 'y' || "${PUBLIC}" == 'Y' ]]; then
    PUBLIC='true'
  fi

  read -p 'User credential (user): ' USER_CREDENTIAL

  [ "${USER_CREDENTIAL}" == '' ] && USER_CREDENTIAL='user'

  read -p 'Domain credential (google.com) *: ' DOMAIN_CREDENTIAL

  if [ "${DOMAIN_CREDENTIAL}" == '' ]; then
    echo -e "\n${RED}Missing domain credential!${NO_COLOR}\n" && exit 1
  fi

  read -p "Remote user dir (/home/${USER_CREDENTIAL}): " REMOTE_DIR

  [ "${REMOTE_DIR}" == '' ] && REMOTE_DIR=/home/$USER_CREDENTIAL

  REMOTE_KEY_NAME_DEFAULT=$(echo $KEY_PATH | rev | cut -d '/' -f 1 | rev)

  read -p "Remote key name (${REMOTE_KEY_NAME_DEFAULT}): " REMOTE_KEY_NAME

  if [ "${REMOTE_KEY_NAME}" == '' ]; then
    REMOTE_KEY_NAME=${REMOTE_KEY_NAME_DEFAULT}
  fi
}

begin() {
  echo -e "-------------------------------------"
  echo -e "${GRAY}Starting ${JOB_NAME}...${NO_COLOR}\n"
}

end() {
  echo -e "${GREEN}Done!${NO_COLOR}"
  echo -e "-------------------------------------\n"
}

upload() {
  REMOTE=${USER_CREDENTIAL}@${DOMAIN_CREDENTIAL}:${REMOTE_DIR}/.ssh/${REMOTE_KEY_NAME}

  if [ $PUBLIC == 'true' ]; then
    echo -e "\n${YELLOW}scp ${KEY_PATH}.pub ${REMOTE}${NO_COLOR}"

    scp ${KEY_PATH}.pub $REMOTE
  fi

  if [ $PRIVATE == 'true' ]; then
    echo -e "\n${YELLOW}scp $KEY_PATH ${REMOTE}${NO_COLOR}"

    scp $KEY_PATH $REMOTE
  fi
}

###################
# --- install --- #
###################

begin

ask
upload

end
