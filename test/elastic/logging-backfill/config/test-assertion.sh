#!/bin/sh

function command_exists() {
  type "$1" &> /dev/null
}

function remove_trailing_slash() {
    echo "$1" | sed 's/\/*$//g'
}

if ! command_exists curl; then
  echo "[ERROR] command 'curl' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if [ -z "$ES_USERNAME" ];
then
  echo "[ERROR] could not variable ES_USERNAME. Aborting.";
  exit 5;
fi

if [ -z "$ES_PASSWORD" ];
then
  echo "[ERROR] could not variable ES_PASSWORD. Aborting.";
  exit 5;
fi

if [ -z "$ES_HOST" ];
then
  echo "[ERROR] could not variable ES_HOST. Aborting.";
  exit 5;
fi

INDEX=$1
AUTHENTICATION=$(echo -n ${ES_USERNAME}:${ES_PASSWORD} | base64 -w 0)
ES_HOST=$(remove_trailing_slash $ES_HOST)


echo "[INFO] Attempting to validate elasticdump completion. host: $ES_HOST; index: $INDEX"

FAILED=false

if [ $(curl -LI  "$ES_HOST/$INDEX/_doc/1" -u $ES_USERNAME:$ES_PASSWORD -o /dev/null -w '%{http_code}\n' -s) != "200" ]; then
  echo "[FAIL] Did not find document $ES_HOST/$INDEX/_doc/1; export dump failed."
  FAILED=true
else
  echo "[PASS] Detected document $ES_HOST/$INDEX/_doc/1"
fi

if [ $(curl -LI  "$ES_HOST/$INDEX/_doc/2" -u $ES_USERNAME:$ES_PASSWORD -o /dev/null -w '%{http_code}\n' -s) != "200" ]; then
  echo "[FAIL] Did not find document $ES_HOST/$INDEX/_doc/2; export dump failed."
  FAILED=true
else
  echo "[PASS] Detected document $ES_HOST/$INDEX/_doc/2"
fi

if [[ "$FAILED" == true ]]; then
  exit 5
fi

echo ""
echo "[INFO] Completed"
