#!/bin/bash

PROTOCOL=${ELASTICSEARCH_PROTOCOL:-https}
PORT=${ELASTICSEARCH_PORT:-443}

function command_exists() {
  type "$1" &> /dev/null
}

function index_exists() {
  indices_count=$(curl --insecure --silent --location --request GET "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_cat/indices?format=json&index=access-$1-*" --header 'kbn-xsrf: true'  -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' | jq '. | length')

  if [[ "$indices_count" -gt "0" ]]; then
    return 0
  else
    return 1
  fi
}

function alias_contains_index() {
  indices_count=$(curl --insecure --silent --location --request GET "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/access-$1-*/_alias/7days-access/" --header 'kbn-xsrf: true'  -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' | grep -v "error" | jq '. | length')

  if [[ "$indices_count" -gt "0" ]]; then
    return 0
  else
    return 1
  fi
}

function clear_alias() {
  INDICES=$(curl --insecure --silent --location --request GET "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_cat/aliases/7days-access/?pretty&s=index&h=index" --header 'kbn-xsrf: true'  -u $KB_USER:$KB_PASSWORD)

  IFS=$'\n'
  DATA=""

  for index in $INDICES
  do
    if ! [[ -z "$DATA" ]]; then
      DATA="$DATA,"
    fi

    DATA="$DATA{ \"remove\": { \"index\": \"$index\", \"alias\": \"7days-access\" } }"
  done

  if [[ -z "$DATA" ]]; then
      return 0
  fi

  DATA="{ \"actions\": [$DATA] }"
  echo "[INFO] attempting to clear alias of old indices references. request: $DATA"
  curl --insecure --location --request POST "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_aliases" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' --data "$DATA"
}

if ! command_exists curl; then
  echo "[ERROR] command 'curl' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if ! command_exists jq; then
  echo "[ERROR] command 'jq' does not exist, unable to continue with execution. Aborting.";
  exit 4
fi

if ! command_exists grep; then
  echo "[ERROR] command 'grep' does not exist, unable to continue with execution. Aborting.";
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

DATE=$(date +%Y.%m.%d)

if alias_contains_index "$DATE"; then
  echo "[INFO] todays index is already covered by the 7days-access alias; aborting."
  exit 0;
fi

# Okay now we need to prepare a remove alias json content for us to delete the 7days-access alias
clear_alias

ALIASES=$(cat /usr/share/aliases/7days-access.json)
echo "[DEBUG] evaluating the aliase: $ALIASES"

echo "[DEBUG] checking to see if index exists for now-7 days."
DATE=$(date --date="7 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-7d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-6 days."
DATE=$(date --date="6 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-6d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-5 days."
DATE=$(date --date="5 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-5d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-4 days."
DATE=$(date --date="4 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-4d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-3 days."
DATE=$(date --date="3 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-3d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-2 days."
DATE=$(date --date="2 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-2d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now-1 days."
DATE=$(date --date="1 days ago" +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d-1d}-*>"))')
fi

echo "[DEBUG] checking to see if index exists for now."
DATE=$(date +%Y.%m.%d)
if ! index_exists "$DATE"; then
  ALIASES=$(echo $ALIASES | jq 'del(.actions[] | select(.add.index == "<access-{now/d}-*>"))')
fi

echo ""
echo "[INFO] Attempting to create alias 7days-access to be recreated since todays index does not exist within the alias. aliases: $ALIASES"
curl --insecure --location --request POST "${PROTOCOL}://$ELASTICSEARCH_HOST:${PORT}/_aliases" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD --header 'Content-Type: application/json' --data "$ALIASES"

echo ""
echo "[INFO] Completed."
