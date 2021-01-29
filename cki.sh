#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

cki_has() {
  type "$1" > /dev/null 2>&1
}

cki_echo() {
  echo
  echo "~~ $1 ~~"
  echo
}


cki_go() {
  local nspace
  local info

  if cki_has kubectl; then
    read -rep "Enter your namespace   : " nspace
    read -rep "Enter cluster resources to describe   : " -i 'ns svc sc node pv' cluster-resources
    read -rep "Enter namespace resources to describe   : " -i 'role rolebinding service sa sts pvc pod' ns-resources

    # cluster info
    info=('version --short' 'get cs -A' 'get netpol -A -o wide' 'api-versions' 'api-resources -o wide' 'get apiservices.apiregistration.k8s.io')
    for ci in "${info[@]}"
    do
      cki_echo ${ci}
      kubectl ${ci}
    done

    >k8s-info.log 2>&1

    # cluster resources
    for cr in "${cluster-resources}"
    do
      cki_echo ${cr}
      kubectl describe $(kubectl get ${cr} -o name)
    done

    >k8s-resources.yaml 2>&1

    # namespace specific resources
    for nr in "${ns-resources}"
    do
      cki_echo ${nr}
      kubectl describe $(kubectl get ${nr} -o name -n $nspace) -n $nspace
    done

    >>k8s-resources.yaml 2>&1

  else
    echo >&2 'You need kubectl to run this script.'
    exit 1
  fi

  cki_reset
}

cki_reset() {
  unset -f cki_has cki_echo cki_go
}

cki_go

} # this ensures the entire script is downloaded #