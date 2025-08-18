#!/bin/bash

PROTOCOL=${ELASTICSEARCH_PROTOCOL:-https}
PORT=${ELASTICSEARCH_PORT:-443}

function command_exists() {
  type "$1" &> /dev/null
}

function create_index() {
  #echo "find indices on ${PROTOCOL}://${ELASTICSEARCH_HOST}:${PORT}/..."
  indices_count=$(curl --insecure --silent --location --request GET "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_cat/indices?format=json&index=access-$1-*" --header 'kbn-xsrf: true'  -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' | jq '. | length')

  if [[ "$indices_count" -gt "0" ]]; then
    echo "[INFO] Have determined that there is an index that matches up with access-$1-*; count: $indices_count"
  else
     echo "[INFO] Did not detect any indices matching access-$1-*; creating a new index access-$1-000000"
     #echo "create index on ${PROTOCOL}://${ELASTICSEARCH_HOST}:${PORT}/..."
     curl --insecure --location --request PUT "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/access-$1-000000" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD;
  fi
  echo ""
}

if ! command_exists curl; then
  echo "[ERROR] command 'curl' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if ! command_exists jq; then
  echo "[ERROR] command 'jq' does not exist, unable to continue with execution. Aborting.";
  exit 4
fi

if [ -z "$ELASTICSEARCH_HOST" ];
then
  echo "[ERROR] could not variable ELASTICSEARCH_HOST. Aborting.";
  exit 5;
fi

if [ -z "$KB_USER" ];
then
  echo "[ERROR] could not variable KB_USER. Aborting.";
  exit 6;
fi

if [ -z "$KB_PASSWORD" ];
then
  echo "[ERROR] could not variable KB_PASSWORD. Aborting.";
  exit 7;
fi

DATE=$(date --date="10 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="9 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="8 days ago" +%Y.%m.%d)
create_index "$DATE"

# We want to create the last 7-8 indices if they dont exist; this is so that the
# alias can be created. These get backfilled as needed by logstash-kafka.

DATE=$(date --date="7 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="6 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="5 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="4 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="3 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="2 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date --date="1 days ago" +%Y.%m.%d)
create_index "$DATE"

DATE=$(date +%Y.%m.%d)
create_index "$DATE"

#echo "[INFO] Creating 7days-access alias ..."
curl --insecure --location --request POST "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_aliases" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' --data @/usr/share/aliases/7days-access.json;

echo ""
echo "[INFO] Completed."
