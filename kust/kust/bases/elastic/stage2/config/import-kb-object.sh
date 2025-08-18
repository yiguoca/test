#!/bin/bash

PROTOCOL=${KB_PROTOCOL:-https}
PORT=${KB_PORT:-443}

function command_exists() {
  type "$1" &> /dev/null
}

if ! command_exists curl; then
  echo "[ERROR] command 'curl' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if [ -z "$KB_HOST" ];
then
  echo "[ERROR] could not variable KB_HOST. Aborting.";
  exit 3;
fi

if [ -z "$KB_USER" ];
then
  echo "[ERROR] could not variable KB_USER. Aborting.";
  exit 3;
fi

if [ -z "$KB_PASSWORD" ];
then
  echo "[ERROR] could not variable KB_PASSWORD. Aborting.";
  exit 3;
fi

OBJECT_TYPE=$1
FILEPATH=$2
OBJECT_IDENTIFIER=$3

if [ -z "$OBJECT_TYPE" ]; then
    echo "[ERROR] The provided kibana object type was not provided. Aborting; value: $OBJECT_TYPE; arguments: $@"
    exit 3
fi

if ! [ -f "$FILEPATH" ]; then
    echo "[ERROR] The provided file path does not exist or cannot be access. Aborting; value: $FILEPATH; arguments: $@"
    exit 3
fi

if [ -z "$OBJECT_IDENTIFIER" ]; then
  echo "[INFO] The object identifier (3rd arugment) was not provided; creating identifier from filename."
  OBJECT_IDENTIFIER=$(basename "${FILEPATH%.*}")
fi

curl --insecure --location --request POST "${PROTOCOL}://$KB_HOST:${PORT}/api/saved_objects/$OBJECT_TYPE/$OBJECT_IDENTIFIER?overwrite=true" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' --data @$FILEPATH
