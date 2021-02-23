#!/bin/bash

{ # this ensures the entire script is downloaded #

SCRIPT_HEADER=(
"# -----------------------------------------------------"
"# Quickly collect K8s info for better troubleshooting. "
"#                                                      "
"# Author : Keegan Mullaney                             "
"# Company: New Relic                                   "
"# Email  : kmullaney@newrelic.com                      "
"# Website: github.com/keegoid-nr/cki                   "
"# License: MIT                                         "
"#                                                      "
"# debug mode:                                          "
"# export CKI_DEBUG=1; ./cki.sh                         "
"# -----------------------------------------------------"
)

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
declare -r RED_BLACK="${COLOR};${BG}${RED};${FG}${BLACK}m"
declare -r TEAL_BLACK="${COLOR};${BG}${TEAL};${FG}${BLACK}m"
declare -r PURPLE_BLACK="${COLOR};${BG}${PURPLE};${FG}${BLACK}m"
declare -r BLUE_BLACK="${COLOR};${BG}${BLUE};${FG}${BLACK}m"
declare -r YELLOW_BLACK="${COLOR};${BG}${YELLOW};${FG}${BLACK}m"
declare -r GREEN_BLACK="${COLOR};${BG}${GREEN};${FG}${BLACK}m"
declare -r BLACK_WHITE="${COLOR};${BG}${BLACK};${FG}${WHITE}m"

# --------------------------  FOREGROUND COLORS

declare -r NONE_GRAY="${COLOR};0;${FG}${GRAY}m"
declare -r NONE_RED="${COLOR};0;${FG}${RED}m"
declare -r NONE_TEAL="${COLOR};0;${FG}${TEAL}m"
declare -r NONE_PURPLE="${COLOR};0;${FG}${PURPLE}m"
declare -r NONE_BLUE="${COLOR};0;${FG}${BLUE}m"
declare -r NONE_YELLOW="${COLOR};0;${FG}${YELLOW}m"
declare -r NONE_GREEN="${COLOR};0;${FG}${GREEN}m"
declare -r NONE_BLACK="${COLOR};0;${FG}${BLACK}m"

# --------------------------  DEFAULT

declare -r NONE_WHITE="${COLOR};0;${FG}${WHITE}m"

# --------------------------  COLORED SYMBOLS

declare -r GRAY_HASH="${NONE_GRAY}#${NONE_WHITE}"
declare -r RED_HASH="${NONE_RED}#${NONE_WHITE}"
declare -r TEAL_HASH="${NONE_TEAL}#${NONE_WHITE}"
declare -r PURPLE_HASH="${NONE_PURPLE}#${NONE_WHITE}"
declare -r BLUE_HASH="${NONE_BLUE}#${NONE_WHITE}"
declare -r YELLOW_HASH="${NONE_YELLOW}#${NONE_WHITE}"
declare -r GREEN_HASH="${NONE_GREEN}#${NONE_WHITE}"
declare -r BLACK_HASH="${NONE_BLACK}#${NONE_WHITE}"

declare -r GRAY_CHK="${NONE_GRAY}✔${NONE_WHITE}"
declare -r RED_CHK="${NONE_RED}✔${NONE_WHITE}"
declare -r TEAL_CHK="${NONE_TEAL}✔${NONE_WHITE}"
declare -r PURPLE_CHK="${NONE_PURPLE}✔${NONE_WHITE}"
declare -r BLUE_CHK="${NONE_BLUE}✔${NONE_WHITE}"
declare -r YELLOW_CHK="${NONE_YELLOW}✔${NONE_WHITE}"
declare -r GREEN_CHK="${NONE_GREEN}✔${NONE_WHITE}"
declare -r BLACK_CHK="${NONE_BLACK}✔${NONE_WHITE}"

declare -r YELLOW_X="${NONE_YELLOW}✘${NONE_WHITE}"
declare -r RED_X="${NONE_RED}✘${NONE_WHITE}"

# --------------------------  LIBRARIES

lib_has() {
  type "$1" > /dev/null 2>&1
}

lib_echo() {
  echo
  echo "~~~ ${1} ~~~"
  echo
}

# trim shortest pattern from the right
# $1 -> string
# $2 -> pattern
lib_trim_shortest_right_pattern() {
  echo -n "${1%$2*}"
}

# trim longest pattern from the left
# $1 -> string
# $2 -> pattern
lib_trim_longest_left_pattern() {
  echo -n "${1##*$2}"
}

# --------------------------  USER IO

# wait for user to press enter or Ctrl=Z
# $1 -> string (optional)
# $2 -> boolean
lib_pause() {
  local prompt="$1"
  local back="$2"
  # default message
  [ -z "${prompt}" ] && prompt="Press [Enter] key to continue"
  # how to go back, with either default or user message
  [ "$back" == true ] && prompt="${prompt}, [Ctrl+Z] to go back"
  read -rp "$prompt..."
}

lib_confirm() {
  local text="$1"
  local preferYes="$2" # optional

  # check preference
  if [ -n "${preferYes}" ] && [ "${preferYes}" == true ]; then
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
lib_msg() {
  echo -e "$1"
}

# output message with encoded characters and no trailing newline
# $1 -> string
lib_msg2() {
  echo -ne "$1"
}

lib_alert() {
  lib_msg "${RED_BLACK} ${1}${2} ${NONE_WHITE}"
  lib_pause
}

lib_notify() {
  lib_msg "${GRAY_BLACK} ${1}${2} ${NONE_WHITE}"
}

lib_notify2() {
  lib_msg "${YELLOW_BLACK} ${1}${2} ${NONE_WHITE}"
}

lib_notify3() {
  lib_msg "${BLUE_BLACK} ${1}${2} ${NONE_WHITE}"
}

# select a numbered item from an array
lib_select ()
{
  select item; do # in "$@" is the default
    if [ "$REPLY" -eq 1 ] || [ "$REPLY" -eq 2 ];
    then
      lib_notify "Going back..." >&2
      return 1
    elif [ "$REPLY" -gt 2 ] && [ "$REPLY" -le $# ];
    then
      lib_notify "Using: $item" >&2
      echo "$item"
      return 0
    else
      lib_notify2 "Incorrect Input: Select a number 1-$#" >&2
    fi
  done
}

lib_progress_bar() {
  case "$1" in
    "0"  ) lib_msg2 "                                        ( 0%   )\r";;
    "5"  ) lib_msg2 "${GRAY_HASH}                                        ( 5%   )\r";;
    "10" ) lib_msg2 "${GRAY_HASH} ${RED_HASH}                                     ( 10%  )\r";;
    "15" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}                                   ( 15%  )\r";;
    "20" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}                                 ( 20%  )\r";;
    "25" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}                               ( 25%  )\r";;
    "30" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}                             ( 30%  )\r";;
    "33" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                           ( 33%  )\r";;
    "35" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                           ( 35%  )\r";;
    "40" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}                         ( 40%  )\r";;
    "45" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}                       ( 45%  )\r";;
    "50" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}                     ( 50%  )\r";;
    "55" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}                   ( 55%  )\r";;
    "60" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                 ( 60%  )\r";;
    "65" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}               ( 65%  )\r";;
    "66" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}               ( 66%  )\r";;
    "70" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}             ( 70%  )\r";;
    "75" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}           ( 75%  )\r";;
    "80" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}         ( 80%  )\r";;
    "85" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}       ( 85%  )\r";;
    "90" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}     ( 90%  )\r";;
    "95" ) lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}   ( 95% )\r";;
    "100") lib_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ( 100% )\r";;
        *) lib_notify2 "not a valid progress bar value: $1"
  esac
}

# --------------------------  ERROR HANDLING

# display success message
# $1 -> string
# $2 -> string
lib_success() {
  if [ -z "$RET" ] || [ "$RET" -eq 0 ]; then
    lib_msg "${GREEN_CHK} ${1}${2}"
    # lib_pause
  fi
}

# display warn message
# $1 -> string
# $2 -> string
lib_warn() {
  if [ "$RET" -gt 0 ]; then
    lib_msg "${YELLOW_X} ${FUNCNAME[1]}(${BASH_LINENO[0]}) - Warning: ${1}${2}"
    lib_pause
  fi
}

# display error message
# $1 -> string
# $2 -> string
lib_error() {
  if [ "$RET" -gt 0 ]; then
    lib_msg "${RED_X} ${FUNCNAME[1]}(${BASH_LINENO[0]}) - An error has occurred. ${1}${2}"
    lib_pause
  fi
}

# check if variable is set
# $1 -> string
lib_variable_set() {
  [ -z "$1" ] && lib_error "${FUNCNAME[1]}(${BASH_LINENO[0]}) - Variable not set." && exit 1
}

# check if module is installed, otherwise install it
# $1 -> string
lib_npm_must_exist() {
  if ! npm ls -gs | grep -q "${1}@"; then
    lib_notify2 "$1 must be installed to continue."
    lib_pause "Press [Enter] to install it with npm" true
    if [ -f "$HOME"/.nvm/nvm.sh ]; then
      npm install -g "$1"
      lib_pause
    else
      sudo npm install -g "$1"
      lib_pause
    fi
  fi
}

lib_brew_must_exist() {
  local brewPath
  brewPath="$(which brew)"

  [ -z "${brewPath}" ] && lib_alert "brew not found in PATH...skipping" && return

  if ! brew list --formula | grep -q "${1}"; then
    lib_notify2 "$1 must be installed to continue."
    lib_pause "Press [Enter] to install it with brew" true
    brew install "$1"
    lib_pause
  fi
}

lib_stack_trace() {
  local i
  lib_notify3 "${1}"
  lib_notify2 "STACK TRACE"
  for (( i=1; i<${#FUNCNAME[*]}; i++ )); do
    lib_notify2 "  ${FUNCNAME[$i]}(${BASH_LINENO[$i-1]})"
  done
}

# --------------------------  SETUP PARAMETERS

# run with environment variable
# export CKI_DEBUG=1; ./cki.sh
# to see debug info
[ -z "$CKI_DEBUG" ] && CKI_DEBUG=0

CKI_APP_NAME="cki"
CKI_OS="$(uname -s)"
CKI_DIR="$(pwd)/"

# --------------------------  ERROR HANDLING

# error handling
# $1 -> path to output file
cki_handle_error() {
  local path="${1}"
  local lineCnt
  local errorCnt
  lineCnt=$(wc -l "${path}" | awk '{print $1}')
  errorCnt=$(grep -v "error\ 'pods\|Error\ from\ server\ (NotFound)" "$path" | grep -c "error\|Error")

  # set the return value by count of lines and errors in results in file
  { [ "$lineCnt" -gt 0 ] && [ "$errorCnt" -eq 0 ] && RET=0; } || { [ "$lineCnt" -gt 0 ] && [ "$errorCnt" -gt 0 ] && RET=1; } || { [ "$lineCnt" -eq 0 ] && RET=2; }

  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "lineCnt=$lineCnt, errorCnt=$errorCnt, RET=$RET"
  { [ $CKI_DEBUG -eq 1 ] && [ "$RET" -gt 0 ]; } && lib_stack_trace "${path}"

  if [ "$RET" -eq 1 ]; then
    lib_warn "There were some errors reported in: ${path}"
  elif [ "$RET" -gt 1 ]; then
    lib_error "There was an error and execution was halted!"
    lib_stack_trace "${path}"
    exit 1
  else
    lib_success "Successfully saved results to: ${path}"
  fi
}

# --------------------------  LOGIC FUNCTIONS

# save first two arguments, then shift twice to save remaining array arguments
cki_kubectl() {
  local path="$1"
  local ns="$2"
  local subjects
  shift 2
  local commands=("$@")
  local cnt=1
  local max=${#commands[@]}
  local step=$(( ( 100 - 100 % max ) / max ))
  local alignedStep=$(( step - step % 5 ))

  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "step=$step"
  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "aligned step=$alignedStep"

  # remove file if it already exists
  rm --preserve-root "$path" 2>/dev/null
  echo

  for res in "${commands[@]}"
  do
    lib_echo "$res" &>>"$path"
    if [ "$ns" == "foo" ]; then
      kubectl $res &>>"$path"
    elif [ "$ns" == "bar" ]; then
      subjects=$(kubectl get $res -o name)
      if [ -z "$subjects" ]; then
        echo "nothing found" &>>"$path"
      else
        kubectl describe $subjects &>>"$path"
      fi
    else
      subjects=$(kubectl get $res -o name -n "$ns")
      if [ -z "$subjects" ]; then
        echo "nothing found" &>>"$path"
      else
        kubectl describe $subjects -n "$ns" &>>"$path"
      fi
    fi
    lib_progress_bar $((alignedStep * cnt))
    cnt=$(( cnt + 1 ))
  done

  # remove any private location keys from results
  sed -i -e 's/[[:alpha:]]\{4\}-[[:alpha:]]\{2\}[[:alnum:]]\{33\}/~~~REMOVED~~~/g' "$path"

  lib_progress_bar 100
  echo -ne '\n'
  cki_handle_error "$path"
}

# --------------------------  MAIN FUNCTIONS

# display a loading message to help give the impression it is doing something important
cki_loading() {
  # make sure we're always starting from the right place
  cd "$CKI_DIR" || exit

  local i=0
  echo
  echo "L O A D I N G . . ."
  while [ $i -le 100 ]
  do
    lib_progress_bar $i
    i=$((i+10))
    sleep 0.1
  done
  clear
}

# print header
cki_print() {
  for line in "${SCRIPT_HEADER[@]}"
  do
    echo "$line"
  done

  echo

  # print out variable values in debug mode
  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "**Debug mode enabled**"
  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "CKI_APP_NAME=$CKI_APP_NAME"
  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "CKI_OS=$CKI_OS"
  [ $CKI_DEBUG -eq 1 ] && lib_notify3 "CKI_DIR=$CKI_DIR"
}

# execute main script function to collect Kubernetes info
cki_go() {
  local nspace
  local cinfo

  if lib_has kubectl; then
    read -rep "Enter your namespace                  : " nspace
    read -rep "Enter cluster resources to describe   : " -i 'ns svc sc node pv' -a cres
    read -rep "Enter namespace resources to describe : " -i 'role rolebinding service sa sts pvc pod' -a nsres

    # cluster info
    cinfo=('version --short' 'get cs -A' 'get netpol -A -o wide' 'api-versions' 'api-resources -o wide' 'get apiservices.apiregistration.k8s.io')
    [ ${#cinfo[@]} -gt 0 ] && cki_kubectl "k8s-info.log" "foo" "${cinfo[@]}"

    # cluster resources
    [ ${#cres[@]} -gt 0 ] && cki_kubectl "k8s-resources.yaml" "bar" "${cres[@]}"

    # namespace specific resources
    [ ${#nsres[@]} -gt 0 ] && cki_kubectl "k8s-$nspace.yaml" "$nspace" "${nsres[@]}"
  else
    echo >&2 'You need kubectl to run this script.'
    exit 1
  fi
}

# display message before exit
cki_exit() {
  if lib_has figlet; then
    lib_msg             "Thanks for using ${CKI_APP_NAME}!" | figlet -f small
  else
    lib_msg             "Thanks for using ${CKI_APP_NAME}!"
  fi
  lib_msg             "(c) $(date +%Y) Keegan Mullaney (TSE), New Relic, MIT License"
}

# unset functions to free up memmory
cki_reset() {
  unset -f cki_loading cki_print cki_go cki_exit cki_reset
}

# --------------------------  MAIN

cki_loading
cki_print
cki_go
cki_exit
cki_reset

} # this ensures the entire script is downloaded #