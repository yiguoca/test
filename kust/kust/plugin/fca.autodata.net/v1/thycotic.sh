if [ "${STUB_THYCOTIC}" != "" ]
then
get_secret() {
  echo "secret"
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
    CACHE_DIR="${BASEDIR}/plugin/fca.autodata.net/v1/.secret-cache"
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
  if [ $(stat -c%s "${SECRET_FILE}") = 0 ]
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
      UC_SECRET_FIELD=$(echo $SECRET_FIELD | sed -s 's/\b\(.\)/\u\1/g')
      # Translate JSON escapes (-e) and don't echo a newline (-n)
      echo -en "$(grep -Poi '"'"${UC_SECRET_FIELD}"'":"[^"]*"' "${SECRET_FILE}" | cut -d: -f2- | head -c -1)"
    fi
  fi
}
fi
