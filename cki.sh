#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

echo "# -----------------------------------------------------"
echo "# Quickly clean Node Agent logs so you can find the    "
echo "# snails through the weeds.                            "
echo "#                                                      "
echo "# Author : Keegan Mullaney                             "
echo "# Company: New Relic                                   "
echo "# Email  : kmullaney@newrelic.com                      "
echo "# Website: source.datanerd.us/tech-support/node-collab "
echo "# License: ISC                                         "
echo "#                                                      "
echo "# run with:                                            "
echo "# export LC_DEBUG=1; ./logclean.sh                     "
echo "# to prevent clearing the screen and print debug lines "
echo "# -----------------------------------------------------"

# --------------------------  DECLARE COLOR VARIABLES

declare -r COLOR='\033[0'

declare -r BLACK='0'
declare -r RED='1'
declare -r GREEN='2'
declare -r YELLOW='3'
declare -r BLUE='4'
declare -r PURPLE='5'
declare -r TEAL='6'
declare -r GRAY='7'
declare -r WHITE='9'

declare -r FG='3'
declare -r BG='4'

# --------------------------  BACKGROUND COLORS

declare -r GRAY_BLACK="${COLOR};${BG}${GRAY};${FG}${BLACK}m"
declare -r TEAL_BLACK="${COLOR};${BG}${TEAL};${FG}${BLACK}m"
declare -r PURPLE_BLACK="${COLOR};${BG}${PURPLE};${FG}${BLACK}m"
declare -r BLUE_BLACK="${COLOR};${BG}${BLUE};${FG}${BLACK}m"
declare -r YELLOW_BLACK="${COLOR};${BG}${YELLOW};${FG}${BLACK}m"
declare -r GREEN_BLACK="${COLOR};${BG}${GREEN};${FG}${BLACK}m"
declare -r RED_BLACK="${COLOR};${BG}${RED};${FG}${BLACK}m"
declare -r BLACK_WHITE="${COLOR};${BG}${BLACK};${FG}${WHITE}m"

# --------------------------  FOREGROUND COLORS

declare -r NONE_GRAY="${COLOR};0;${FG}${GRAY}m"
declare -r NONE_TEAL="${COLOR};0;${FG}${TEAL}m"
declare -r NONE_PURPLE="${COLOR};0;${FG}${PURPLE}m"
declare -r NONE_BLUE="${COLOR};0;${FG}${BLUE}m"
declare -r NONE_YELLOW="${COLOR};0;${FG}${YELLOW}m"
declare -r NONE_GREEN="${COLOR};0;${FG}${GREEN}m"
declare -r NONE_RED="${COLOR};0;${FG}${RED}m"
declare -r NONE_BLACK="${COLOR};0;${FG}${BLACK}m"

# --------------------------  DEFAULT

declare -r NONE_WHITE="${COLOR};0;${FG}${WHITE}m"

# --------------------------  COLORED SYMBOLS

declare -r GREEN_CHK="${NONE_GREEN}✔${NONE_WHITE}"
declare -r YELLOW_CHK="${NONE_YELLOW}✔${NONE_WHITE}"
declare -r BLUE_CHK="${NONE_BLUE}✔${NONE_WHITE}"
declare -r BLACK_CHK="${NONE_BLACK}✔${NONE_WHITE}"
declare -r RED_X="${NONE_RED}✘${NONE_WHITE}"

# --------------------------  SETUP PARAMETERS

# run with environment variable
# export CKI_DEBUG=1; ./cki.sh
# to see debug info
[ -z $CKI_DEBUG ] && CKI_DEBUG=0

CKI_APP_NAME="cki"
CKI_OS="$(uname -s)"
CKI_DIR="$(pwd)/"

# --------------------------  LIBRARIES

# wait for user to press enter or Ctrl=Z
# $1 -> string (optional)
# $2 -> boolean
lkm_pause() {
  local prompt="$1"
  local back="$2"
  # default message
  [ -z "${prompt}" ] && prompt="Press [Enter] key to continue"
  # how to go back, with either default or user message
  [ "$back" = true ] && prompt="${prompt}, [Ctrl+Z] to go back"
  read -rp "$prompt..."
}

lkm_confirm() {
  local text="$1"
  local preferYes="$2" # optional

  # check preference
  if [ -n "${preferYes}" ] && [ "${preferYes}" = true ]; then
    # prompt user with preference for Yes
    read -rp "${text} [Y/n] " response
    case $response in
      [nN][oO]|[nN])
        return 1
        ;;
      *)
        return 0
        ;;
    esac
  else
    # prompt user with preference for No
    read -rp "${text} [y/N] " response
    case $response in
      [yY][eE][sS]|[yY])
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  fi
}

# output message with encoded characters
# $1 -> string
lkm_msg() {
  echo -e "$1"
}

# output message with encoded characters and no trailing newline
# $1 -> string
lkm_msg2() {
  echo -ne "$1"
}

lkm_alert() {
  lkm_msg "${RED_BLACK} ${1}${2} ${NONE_WHITE}"
  lkm_pause
}

lkm_notify() {
  lkm_msg "${GRAY_BLACK} ${1}${2} ${NONE_WHITE}"
}

lkm_notify2() {
  lkm_msg "${YELLOW_BLACK} ${1}${2} ${NONE_WHITE}"
}

lkm_notify3() {
  lkm_msg "${BLUE_BLACK} ${2}${3} ${NONE_WHITE}"
}

# display success message
# $1 -> string
# $2 -> string
lkm_success() {
  if [ -z "$RET" ] || [ "$RET" -eq 0 ]; then
    lkm_msg "${BLACK_CHK} ${1}${2}"
  fi
}

# display error message
# $1 -> string
# $2 -> string
lkm_error() {
  if [ "$RET" -gt 0 ]; then
    lkm_msg "${RED_X} ${FUNCNAME[1]}(${BASH_LINENO[0]}): An error has occurred.\n${1}\n${2}"
  fi
}

# check if variable is set
# $1 -> string
lkm_variable_set() {
  [ -z "$1" ] && lkm_error "${FUNCNAME[1]}(${BASH_LINENO[0]}): Variable not set." && exit 1
}

# --------------------------  REQUIREMENTS

# print out variable values in debug mode
[ $CKI_DEBUG -eq 1 ] && lkm_notify3 "LC_APP_NAME=$LC_APP_NAME"
[ $CKI_DEBUG -eq 1 ] && lkm_notify3 "LC_OS=$LC_OS"
[ $CKI_DEBUG -eq 1 ] && lkm_notify3 "LC_DIR=$LC_DIR"

# --------------------------  FUNCTIONS

cki_has() {
  type "$1" > /dev/null 2>&1
}

cki_echo() {
  echo
  echo "~~~ ${1} ~~~"
  echo
}


cki_go() {
  local nspace
  local cinfo

  if cki_has kubectl; then
    read -rep "Enter your namespace                  : " nspace
    read -rep "Enter cluster resources to describe   : " -i 'ns svc sc node pv' cres
    read -rep "Enter namespace resources to describe : " -i 'role rolebinding service sa sts pvc pod' nsres

    # cluster info
    info=('version --short' 'get cs -A' 'get netpol -A -o wide' 'api-versions' 'api-resources -o wide' 'get apiservices.apiregistration.k8s.io')
    for ci in "${cinfo[@]}"
    do
      cki_echo "${ci}"
      kubectl $ci
    done >k8s-info.log 2>&1

    lkm_success "Successfully created: k8s-info.log"
    lkm_msg2 "${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK}                     (33%)\r"

    # cluster resources
    for cr in $cres
    do
      cki_echo $cr
      kubectl describe $(kubectl get $cr -o name)
    done >k8s-resources.yaml 2>&1

    lkm_success "Successfully created: k8s-resources.yaml"
    lkm_msg2 "${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK}           (66%)\r"

    # namespace specific resources
    for nr in $nsres
    do
      cki_echo $nr
      kubectl describe $(kubectl get $nr -o name -n $nspace) -n $nspace
    done >>k8s-resources.yaml 2>&1

    lkm_success "Successfully appended to: k8s-resources.yaml"
    lkm_msg2 "${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} ${YELLOW_CHK} ${BLUE_CHK} ${GREEN_CHK} (100%)\r"
    echo -ne '\n'
  else
    echo >&2 'You need kubectl to run this script.'
    exit 1
  fi
}

cki_reset() {
  unset -f cki_has cki_echo cki_go
}

# --------------------------  MAIN

cki_go
cki_reset

} # this ensures the entire script is downloaded #