#!/bin/sh

function command_exists() {
  type "$1" &> /dev/null
}

if ! command_exists elasticdump; then
  echo "[ERROR] command 'elasticdump' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if ! command_exists base64; then
  echo "[ERROR] command 'base64' does not exist, unable to continue with execution. Aborting.";
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

if [ -z "$TARGET" ];
then
  echo "[ERROR] could not variable TARGET. Aborting.";
  exit 5;
fi

if [ -z "$SOURCE" ];
then
  echo "[ERROR] could not variable SOURCE. Aborting.";
  exit 5;
fi

AUTHENTICATION=$(echo -n ${ES_USERNAME}:${ES_PASSWORD} | base64 -w 0)

echo "[INFO] Executing elasticdump to import data. source: $SOURCE; target: $TARGET; limit: $LIMIT"

elasticdump --input=$SOURCE --output=$TARGET --type=${DATA:-"data"} --size=${SIZE:-"-1"} --limit=${LIMIT:-"600"} $ADDITIONAL_ARGS --headers="{\"Authorization\": \"Basic ${AUTHENTICATION}\"}"

echo "[INFO] Completed"
