#!/bin/sh

function command_exists() {
  type "$1" &> /dev/null
}

function create_index() {
  indices_count=$(curl --silent --location --request GET "https://$ES_HOST/_cat/indices?format=json&index=$1" --header 'kbn-xsrf: true'  -u $ES_USERNAME:$ES_PASSWORD --header 'Content-Type: application/json' | jq '. | length')

  if [[ "$indices_count" -gt "0" ]]; then
    echo "[INFO] Have determined that there is an index that matches up with $1; count: $indices_count"
  else
     echo "[INFO] Did not detect any indices matching $1; creating a new index $1"
     curl --location --request PUT "https://$ES_HOST/$1" --header 'kbn-xsrf: true' -u $KB_USER:$KB_PASSWORD;
  fi
  echo ""
}

function remove_trailing_slash() {
    echo "$1" | sed 's/\/*$//g'
}

if ! command_exists curl; then
  echo "[ERROR] command 'curl' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if ! command_exists jq; then
  echo "[ERROR] command 'jq' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi

if ! command_exists sed; then
  echo "[ERROR] command 'sed' does not exist, unable to continue with execution. Aborting.";
  exit 3
fi


if  [ -z "$ES_USERNAME" ];
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

echo "[INFO] Attempting to prepare elastic for testing elasticdump. host: $ES_HOST; index: $INDEX"

create_index $INDEX

curl --location --request PUT "$ES_HOST/$INDEX/_create/1" \
--header 'Content-Type: application/json' \
--header "Authorization: Basic $AUTHENTICATION" \
--data-raw '{
	"log": {
		"file": {}
	},
	"nginx": {
		"host": "www.jeep.com"
	},
	"photon": {
		"timestamp": "2023-06-26T14:35:16.308Z",
		"cluster": "fcaus-te",
		"datacenter": "London"
	},
	"@timestamp": "2023-06-26T14:35:16.000Z",
	"@version": "1"
}'

curl --location --request PUT "$ES_HOST/$INDEX/_create/2" \
--header 'Content-Type: application/json' \
--header "Authorization: Basic $AUTHENTICATION" \
--data-raw '{
	"log": {
		"file": {}
	},
	"nginx": {
		"host": "www.jeep.com"
	},
	"photon": {
		"timestamp": "2023-06-26T15:35:16.308Z",
		"cluster": "fcaus-te",
		"datacenter": "London"
	},
	"@timestamp": "2023-06-26T15:35:16.000Z",
	"@version": "1"
}'

echo ""
echo "[INFO] Completed"
