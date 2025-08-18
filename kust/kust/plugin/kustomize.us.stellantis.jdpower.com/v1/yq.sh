# shellcheck shell=bash
YQ="$(which yq || echo '')"
if [[ -z "${YQ}" ]]
then
  YQ="$(dirname "$0")/yq"
  if [[ ! -e "${YQ}" ]]
  then
    >&2 echo "Downloading yq"
    OS=$(uname -o)
    case $OS in
      Darwin)
        OS=darwin
        MACHINE=$(uname -m)
        ;;
      GNU/Linux)
        OS=linux
        MACHINE=amd64
        ;;
      Windows)
        OS=windows
        MACHINE=amd64
        YQ="${YQ}.exe"
        ;;
      *)
        >&2 echo "Could not determine OS and machine type for $(uname -o) $(uname -m)"
        exit 1
        ;;
    esac
    curl -sL "https://github.com/mikefarah/yq/releases/latest/download/yq_${OS}_${MACHINE}" -o "${YQ}" && chmod +x "${YQ}"
    if ! "${YQ}" --version >/dev/null 2>&1
    then
      >&2 echo "yq download was not successful"
      exit 1
    fi
  fi
fi
