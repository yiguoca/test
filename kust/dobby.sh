#!/bin/bash
set -eo pipefail

VERB=$1
NAMESPACE=$2

get_user() {
  user="${GITLAB_USER_EMAIL:-${USER}}"
  if [ "${user}" == "root" ]
  then
    user="$(git config user.email)"
  fi
  echo "${user}"
}

kubectl annotate ns $NAMESPACE --overwrite "dobby-$VERB-hash"="$(git rev-parse --short HEAD)" "dobby-$VERB-pipeline-id"="${CI_PIPELINE_ID:-none}" "dobby-$VERB-user"="$(get_user)" "dobby-$VERB-timestamp"="$(date --iso-8601=second)" >/dev/null
