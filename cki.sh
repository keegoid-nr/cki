#!/usr/bin/env bash
SCRIPT_HEADER=(
"# -----------------------------------------------------"
"# Quickly collect K8s info for better troubleshooting  "
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

{ # this ensures the entire script is downloaded #

# --------------------------  DECLARE COLOR VARIABLES

declare -r COLOR='\033[0'

declare -r BLACK='0'
declare -r RED='1'
declare -r GREEN='2'
declare -r YELLOW='3'
declare -r BLUE='4'
# declare -r PURPLE='5'
# declare -r TEAL='6'
declare -r GRAY='7'
declare -r WHITE='9'

declare -r FG='3'
declare -r BG='4'

# --------------------------  BACKGROUND COLORS

declare -r GRAY_BLACK="${COLOR};${BG}${GRAY};${FG}${BLACK}m"
declare -r RED_BLACK="${COLOR};${BG}${RED};${FG}${BLACK}m"
# declare -r TEAL_BLACK="${COLOR};${BG}${TEAL};${FG}${BLACK}m"
# declare -r PURPLE_BLACK="${COLOR};${BG}${PURPLE};${FG}${BLACK}m"
declare -r BLUE_BLACK="${COLOR};${BG}${BLUE};${FG}${BLACK}m"
declare -r YELLOW_BLACK="${COLOR};${BG}${YELLOW};${FG}${BLACK}m"
# declare -r GREEN_BLACK="${COLOR};${BG}${GREEN};${FG}${BLACK}m"
# declare -r BLACK_WHITE="${COLOR};${BG}${BLACK};${FG}${WHITE}m"

# --------------------------  FOREGROUND COLORS

declare -r NONE_GRAY="${COLOR};0;${FG}${GRAY}m"
declare -r NONE_RED="${COLOR};0;${FG}${RED}m"
# declare -r NONE_TEAL="${COLOR};0;${FG}${TEAL}m"
# declare -r NONE_PURPLE="${COLOR};0;${FG}${PURPLE}m"
declare -r NONE_BLUE="${COLOR};0;${FG}${BLUE}m"
declare -r NONE_YELLOW="${COLOR};0;${FG}${YELLOW}m"
declare -r NONE_GREEN="${COLOR};0;${FG}${GREEN}m"
# declare -r NONE_BLACK="${COLOR};0;${FG}${BLACK}m"

# --------------------------  DEFAULT

declare -r NONE_WHITE="${COLOR};0;${FG}${WHITE}m"

# --------------------------  COLORED SYMBOLS

declare -r GRAY_HASH="${NONE_GRAY}#${NONE_WHITE}"
declare -r RED_HASH="${NONE_RED}#${NONE_WHITE}"
# declare -r TEAL_HASH="${NONE_TEAL}#${NONE_WHITE}"
# declare -r PURPLE_HASH="${NONE_PURPLE}#${NONE_WHITE}"
declare -r BLUE_HASH="${NONE_BLUE}#${NONE_WHITE}"
declare -r YELLOW_HASH="${NONE_YELLOW}#${NONE_WHITE}"
declare -r GREEN_HASH="${NONE_GREEN}#${NONE_WHITE}"
# declare -r BLACK_HASH="${NONE_BLACK}#${NONE_WHITE}"

# declare -r GRAY_CHK="${NONE_GRAY}✔${NONE_WHITE}"
# declare -r RED_CHK="${NONE_RED}✔${NONE_WHITE}"
# declare -r TEAL_CHK="${NONE_TEAL}✔${NONE_WHITE}"
# declare -r PURPLE_CHK="${NONE_PURPLE}✔${NONE_WHITE}"
# declare -r BLUE_CHK="${NONE_BLUE}✔${NONE_WHITE}"
# declare -r YELLOW_CHK="${NONE_YELLOW}✔${NONE_WHITE}"
declare -r GREEN_CHK="${NONE_GREEN}✔${NONE_WHITE}"
# declare -r BLACK_CHK="${NONE_BLACK}✔${NONE_WHITE}"

declare -r YELLOW_X="${NONE_YELLOW}✘${NONE_WHITE}"
declare -r RED_X="${NONE_RED}✘${NONE_WHITE}"

# --------------------------  SETUP PARAMETERS

# run with environment variable
# export CKI_DEBUG=1; ./cki.sh
# to see debug info
[ -z "$CKI_DEBUG" ] && CKI_DEBUG=0

CKI_APP_NAME="cki"
CKI_OS="$(uname -s)"
CKI_DIR="$(pwd)/"

# --------------------------  LIBRARIES

cki_has() {
  type "$1" > /dev/null 2>&1
}

cki_echo() {
  echo
  echo "~~~ ${1} ~~~"
  echo
}

# wait for user to press enter or Ctrl=Z
# $1 -> string (optional)
# $2 -> boolean
cki_pause() {
  local prompt="$1"
  local back="$2"
  # default message
  [ -z "${prompt}" ] && prompt="Press [Enter] key to continue"
  # how to go back, with either default or user message
  [ "$back" = true ] && prompt="${prompt}, [Ctrl+Z] to go back"
  read -rp "$prompt..."
}

cki_confirm() {
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
cki_msg() {
  echo -e "$1"
}

# output message with encoded characters and no trailing newline
# $1 -> string
cki_msg2() {
  echo -ne "$1"
}

cki_alert() {
  cki_msg "${RED_BLACK} ${1}${2} ${NONE_WHITE}"
  cki_pause "Press [Enter] key to continue"
}

cki_notify() {
  cki_msg "${GRAY_BLACK} ${1}${2} ${NONE_WHITE}"
}

cki_notify2() {
  cki_msg "${YELLOW_BLACK} ${1}${2} ${NONE_WHITE}"
}

cki_notify3() {
  cki_msg "${BLUE_BLACK} ${1}${2} ${NONE_WHITE}"
}

cki_progress_bar() {
  case "$1" in
    "0"  ) cki_msg2 "                                        ( 0%   )\r";;
    "5"  ) cki_msg2 "${GRAY_HASH}                                        ( 5%   )\r";;
    "10" ) cki_msg2 "${GRAY_HASH} ${RED_HASH}                                     ( 10%  )\r";;
    "15" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}                                   ( 15%  )\r";;
    "20" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}                                 ( 20%  )\r";;
    "25" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}                               ( 25%  )\r";;
    "30" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}                             ( 30%  )\r";;
    "33" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                           ( 33%  )\r";;
    "35" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                           ( 35%  )\r";;
    "40" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}                         ( 40%  )\r";;
    "45" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}                       ( 45%  )\r";;
    "50" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}                     ( 50%  )\r";;
    "55" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}                   ( 55%  )\r";;
    "60" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}                 ( 60%  )\r";;
    "65" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}               ( 65%  )\r";;
    "66" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}               ( 66%  )\r";;
    "70" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}             ( 70%  )\r";;
    "75" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH}           ( 75%  )\r";;
    "80" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH}         ( 80%  )\r";;
    "85" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH}       ( 85%  )\r";;
    "90" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH}     ( 90%  )\r";;
    "95" ) cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH}   ( 95% )\r";;
    "100") cki_msg2 "${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ${GRAY_HASH} ${RED_HASH} ${BLUE_HASH} ${YELLOW_HASH} ${GREEN_HASH} ( 100% )\r";;
        *) cki_notify2 "not a valid progress bar value: $1"
  esac
}

# display success message
# $1 -> string
# $2 -> string
cki_success() {
  if [ -z "$RET" ] || [ "$RET" -eq 0 ]; then
    cki_msg "${GREEN_CHK} ${1}${2}"
  fi
}

# display warn message
# $1 -> string
# $2 -> string
cki_warn() {
  if [ "$RET" -gt 0 ]; then
    cki_msg "${YELLOW_X} ${FUNCNAME[2]}(${BASH_LINENO[1]}) - Warning: ${1}${2}"
  fi
}

# display error message
# $1 -> string
# $2 -> string
cki_error() {
  if [ "$RET" -gt 0 ]; then
    cki_msg "${RED_X} ${FUNCNAME[2]}(${BASH_LINENO[1]}) - An error has occurred. ${1}${2}"
  fi
}

# check if variable is set
# $1 -> string
cki_variable_set() {
  [ -z "$1" ] && cki_error "${FUNCNAME[1]}(${BASH_LINENO[0]}) - Variable not set." && exit 1
}

cki_stack_trace() {
  local i
  cki_notify3 "${1}"
  cki_notify2 "STACK TRACE"
  for (( i=1; i<${#FUNCNAME[*]}; i++ )); do
    cki_notify2 "  ${FUNCNAME[$i]}(${BASH_LINENO[$i-1]})"
  done
}

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

  [ $CKI_DEBUG -eq 1 ] && cki_notify "lineCnt=$lineCnt, errorCnt=$errorCnt, RET=$RET"
  { [ $CKI_DEBUG -eq 1 ] && [ "$RET" -gt 0 ]; } && cki_stack_trace "${path}"

  if [ "$RET" -eq 1 ]; then
    cki_warn "There were some errors reported in: ${path}"
  elif [ "$RET" -gt 1 ]; then
    cki_error "There was an error and execution was halted!"
    cki_stack_trace "${path}"
    exit 1
  else
    cki_success "Successfully saved results to: ${path}"
  fi
}

# display message before exit
cki_exit() {
  if cki_has figlet; then
    cki_msg             "Thanks for using ${CKI_APP_NAME}!" | figlet -f small
  else
    cki_msg             "Thanks for using ${CKI_APP_NAME}!"
  fi
  cki_msg             "(c) $(date +%Y) Keegan Mullaney (TSE), New Relic, MIT License"
}

# --------------------------  FUNCTIONS

# save first two arguments, then shift twice to save remaining array arguments
cki_kubectl() {
  local path="$1"
  local ns="$2"
  shift 2
  local commands=("$@")
  local cnt=1
  local max=${#commands[@]}
  local step=$(( ( 100 - 100 % max ) / max ))
  local alignedStep=$(( step - step % 5 ))

  [ $CKI_DEBUG -eq 1 ] && cki_notify3 "step=$step"
  [ $CKI_DEBUG -eq 1 ] && cki_notify3 "aligned step=$alignedStep"

  # remove file if it already exists
  rm --preserve-root "$path"
  echo

  for res in "${commands[@]}"
  do
    cki_echo "$res" >>"$path" 2>&1
    if [ "$ns" == "foo" ]; then
      kubectl $res >>"$path" 2>&1
    elif [ "$ns" == "bar" ]; then
      kubectl describe $(kubectl get $res -o name) >>"$path" 2>&1
    else
      kubectl describe $(kubectl get $res -o name -n "$ns") -n "$ns" >>"$path" 2>&1
    fi
    cki_progress_bar $((alignedStep * cnt))
    cnt=$(( cnt + 1 ))
  done

  cki_progress_bar 100
  echo -ne '\n'
  cki_handle_error "$path"
}

cki_go() {
  local nspace
  local cinfo

  if cki_has kubectl; then
    read -rep "Enter your namespace                  : " nspace
    read -rep "Enter cluster resources to describe   : " -i 'ns svc sc node pv' -a cres
    read -rep "Enter namespace resources to describe : " -i 'role rolebinding service sa sts pvc pod' -a nsres

    # cluster info
    cinfo=('version --short' 'get cs -A' 'get netpol -A -o wide' 'api-versions' 'api-resources -o wide' 'get apiservices.apiregistration.k8s.io')
    [ ${#cinfo[@]} -gt 0 ] && cki_kubectl "k8s-info.log" "foo" "${cinfo[@]}"

    # cluster resources
    [ ${#cres[@]} -gt 0 ] && cki_kubectl "k8s-resources.yaml" "bar" "${cres[@]}"

    # namespace specific resources
    [ ${#nsres[@]} -gt 0 ] && cki_kubectl "k8s-resources.yaml" "$nspace" "${nsres[@]}"
  else
    echo >&2 'You need kubectl to run this script.'
    exit 1
  fi
}

cki_loading() {
  # make sure we're always starting from the right place
  cd "$CKI_DIR" || exit

  local i=0
  echo
  echo "L O A D I N G . . ."
  while [ $i -le 100 ]
  do
    cki_progress_bar $i
    i=$((i+10))
    sleep 0.1
  done
  clear
}

cki_print() {
  for line in "${SCRIPT_HEADER[@]}"
  do
    echo "$line"
  done

  echo

  # print out variable values in debug mode
  [ $CKI_DEBUG -eq 1 ] && cki_notify3 "**Debug mode enabled**"
  [ $CKI_DEBUG -eq 1 ] && cki_notify "CKI_APP_NAME=$CKI_APP_NAME"
  [ $CKI_DEBUG -eq 1 ] && cki_notify "CKI_OS=$CKI_OS"
  [ $CKI_DEBUG -eq 1 ] && cki_notify "CKI_DIR=$CKI_DIR"
}

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