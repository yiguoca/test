if [ "${STUB_THYCOTIC}" != "" ]
then
get_secret() {
  SECRET_FIELD=$2
  SECRET_TYPE=$3
  # return test pfx key if it is requested
  if [[ "$SECRET_TYPE" = "ssl-certificate" && "$SECRET_FIELD" = "issued-pfx" ]]
  then
      echo -n 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 | base64 --decode
  else
    echo "secret"
  fi
}
else
get_secret() {
  SECRET_ID=$1
  SECRET_FIELD=$2
  SECRET_TYPE=$3
  if [ "$SECRET_TYPE" = "" ]
  then
    SECRET_TYPE=password
  fi
  if [ "${BASEDIR}" != "" ]
  then
    CACHE_DIR="${BASEDIR}/plugin/fca.autodata.net/v1.1/.secret-cache"
  else
    CACHE_DIR="$(dirname $0)/../.secret-cache"
  fi
  if [ ! -d "${CACHE_DIR}" ]
  then
    mkdir -p "${CACHE_DIR}"
  fi
  SECRET_FILE="${CACHE_DIR}/${SECRET_ID}.json"
  if [ "${SECRET_TYPE}" = "ssl-certificate" ]
  then
    SECRET_FILE="${CACHE_DIR}/${SECRET_ID}-${SECRET_FIELD}"
  fi
  if [ ! -f "${SECRET_FILE}" ]
  then
    if [ "${SECRET_TYPE}" = "ssl-certificate" ]
    then
      thycotic get --secret.id ${SECRET_ID} field ${SECRET_TYPE} ${SECRET_FIELD} >${SECRET_FILE}
    elif [ "${SECRET_TYPE}" = "token-file-based" ]
    then
      thycotic get --secret.id ${SECRET_ID} field ${SECRET_TYPE} ${SECRET_FIELD} >${SECRET_FILE}
    else
      # thycotic get returns a JSON array
      thycotic get --secret.id ${SECRET_ID} --output json | sed 's ^\[\(.*\)\]$ \1 ' >"${SECRET_FILE}"
    fi
  fi
  if [[ $(stat "${SECRET_FILE}") = 0 ]]
  then
    echo "Error reading secret ${SECRET_ID}"
    rm "${SECRET_FILE}"
    exit 1
  else
    if [ "${SECRET_TYPE}" = "ssl-certificate" ]
    then
      cat ${SECRET_FILE}
    elif [ "${SECRET_TYPE}" = "token-file-based" ]
    then
      cat ${SECRET_FILE}
    else
      # uppercase each word in the secret
      UC_SECRET_FIELD=$(echo $SECRET_FIELD | sed 's/\b\(.\)/\u\1/g')
      # Translate JSON escapes (-e) and don't echo a newline (-n)
      echo -en "$(grep -oi '"'"${UC_SECRET_FIELD}"'":"[^"]*"' "${SECRET_FILE}" | cut -d: -f2- | tr -d '\n')"
    fi
  fi
}
fi
