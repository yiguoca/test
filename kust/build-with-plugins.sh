#!/bin/bash
set -euo pipefail

MYPATH="$(cd "$(dirname "$0")" || exit 1; pwd -P)"
export KUSTOMIZE_PLUGIN_HOME=${MYPATH}/plugin

if [ "$1" = "" ]
then
  cat >/dev/stderr <<EOF
ERROR: $0 requires an argument.
EOF
  exit 1
fi

if [ "${K8S_VERSION-}" == "" ]
then
  export K8S_VERSION=1.28
fi
KUSTOMIZE_MAJOR_VERSION=$(kustomize version | cut -dv -f2 | cut -d. -f1)
KUSTOMIZE_MINOR_VERSION=$(kustomize version | cut -dv -f2 | cut -d. -f2)
KUSTOMIZE_PATCH_VERSION=$(kustomize version | cut -dv -f2 | cut -d' ' -f1 | cut -d. -f3)

badversion () {
  >&2 cat <<EOF
ERROR: kustom now requires kustomize v5.3 or greater. Please upgrade using
the instructions at https://kubectl.docs.kubernetes.io/installation/kustomize/
EOF
  exit 1
}

if [ ${KUSTOMIZE_MAJOR_VERSION} -lt 5 ]
then
  badversion
elif [[ ${KUSTOMIZE_MAJOR_VERSION} -eq 5 ]]
then
  if [[ ${KUSTOMIZE_MINOR_VERSION} -lt 3 ]] | [[ ${KUSTOMIZE_PATCH_VERSION} -lt 0 ]]
  then
    badversion
  fi
fi

kustomize build --enable-alpha-plugins --enable-exec $*
