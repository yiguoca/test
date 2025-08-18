encode() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    ENCODED_VALUE=$(echo -n "$1" | /usr/bin/base64 -b 0)
  else
    ENCODED_VALUE=$(echo -n "$1" | base64 -w 0)
  fi

  echo -n $ENCODED_VALUE
}
