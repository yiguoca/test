#!/usr/bin/env bash
set -e

for key in $(cat "/usr/share/configs/ilm_policy.json" | jq -r 'keys[]'); do
  val=$(cat "/usr/share/configs/ilm_policy.json" | jq ".\"$key\"")
  echo "Applying ILM Policy: $key"
  curl --fail-with-body --location --request PUT https://$ELASTICSEARCH_HOST/_ilm/policy/$key --header 'kbn-xsrf: true' --cacert $SSL_CERT_FILE -u $ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD --header 'Content-Type: application/json' --data "$val"
done