# shellcheck shell=bash
STUB_THYCOTIC=${STUB_THYCOTIC-}
if [ "${STUB_THYCOTIC}" != "" ]
then
get_secret() {
  echo '"secret"'
}
else
get_secret() {
  SECRET_ID=$1
  SECRET_FIELD=$2
  set +u
  SECRET_TYPE=$3
  set -u
  if [ "$SECRET_TYPE" = "" ]
  then
    SECRET_TYPE=password
  fi
  CACHE_DIR="$(dirname "$0")/.secret-cache"
  if [ ! -d "${CACHE_DIR}" ]
  then
    mkdir -p "${CACHE_DIR}"
  fi
  SECRET_FILE="${CACHE_DIR}/${SECRET_ID}.json"
  if [ ! -f "${SECRET_FILE}" ]
  then
    thycotic get --secret.id "${SECRET_ID}" --output json --expand-files | jq '.[]' >"${SECRET_FILE}"
  fi
  if [ "$(stat -c%s "${SECRET_FILE}")" = 0 ]
  then
    echo "Error reading secret ${SECRET_ID}"
    rm "${SECRET_FILE}"
    exit 1
  else
    UC_SECRET_FIELD=$(echo "${SECRET_FIELD}" | sed -s 's/\b\(.\)/\u\1/g')
    if (grep "${UC_SECRET_FIELD}.*u0000" "${SECRET_FILE}" >/dev/null 2>&1)
    then
      SECRET_FILE="${CACHE_DIR}/${SECRET_ID}.${SECRET_FIELD}"
      if [ ! -f "${SECRET_FILE}" ]
      then
        thycotic get --secret.id "${SECRET_ID}" field "${SECRET_TYPE}" "${SECRET_FIELD}" >"${SECRET_FILE}"
      fi
      if [ "$(stat -c%s "${SECRET_FILE}")" = 0 ]
      then
        echo "Error reading secret ${SECRET_ID}"
        rm "${SECRET_FILE}"
        exit 1
      else
        cat "${SECRET_FILE}"
      fi
    else
      jq -r ".\"${UC_SECRET_FIELD}\"" "${SECRET_FILE}"
    fi
  fi
}
fi
