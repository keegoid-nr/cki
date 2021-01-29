#!/usr/bin/env bash

{ # this ensures the entire script is downloaded #

cki_has() {
  type "$1" > /dev/null 2>&1
}

cki_go() {
  local nspace
  local cluster-info
  local cluster-resources
  local ns-resources

  if cki_has kubectl; then
    read -rep "Enter your namespace   : " -i "" nspace
    read -rep "Enter cluster resources to describe   : " -i "ns svc sc node pv" cluster-resources
    read -rep "Enter namespace resources to describe   : " -i "role rolebinding service sa sts pvc pod" ns-resources
    info=('version --short' 'get cs -A' 'get netpol -A -o wide' 'api-versions' 'api-resources -o wide' 'get apiservices.apiregistration.k8s.io'); for r in "${info[@]}"; do echo; echo "~~ $r ~~"; echo; kubectl $r; done >k8s-info.log 2>&1; for r in $cluster-resources; do echo; echo "~~ $r ~~"; echo; kubectl describe $(kubectl get $r -o name --no-headers=true); done >k8s-resources.yaml 2>&1; for r in $ns-resources; do echo; echo "~~ $r ~~"; echo; kubectl describe $(kubectl get $r -o name -n $nspace) -n $nspace; done >>k8s-resources.yaml 2>&1
  else
    echo >&2 'You need kubectl to run this script.'
    exit 1
  fi

  cki_reset
}

cki_reset() {
  unset -f cki_go
}

cki_go

} # this ensures the entire script is downloaded #