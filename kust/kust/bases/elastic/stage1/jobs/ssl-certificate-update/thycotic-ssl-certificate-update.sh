#!/bin/sh
sleep 1m
CERT_PASSWORD=$(thycotic get --secret.id="$SECRET_ID" field ssl-certificate password | xargs)
echo "$PRIVATE_KEY" > server.key
echo "$PUBLIC_KEY" > server.crt
echo "$CA_CERT" > CACert.crt
thycotic update ssl-certificate field key --secret.id="$SECRET_ID" --secret.field.slug=key -f server.key
thycotic update ssl-certificate field public-certificate --secret.id="$SECRET_ID" --secret.field.slug=public-certificate -f server.crt
openssl pkcs12 -export -out server.pfx -inkey server.key -in server.crt -certfile CACert.crt -password "pass:$CERT_PASSWORD"
thycotic update ssl-certificate field issued-pfx --secret.id="$SECRET_ID" --secret.field.slug=issued-pfx -f server.pfx
