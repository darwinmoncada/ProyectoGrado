#!/bin/sh
set -e

# If DATABASE_URL provided and SPRING_DATASOURCE_URL not set, convert it
if [ -n "$DATABASE_URL" ] && [ -z "$SPRING_DATASOURCE_URL" ]; then
  # Remove scheme
  proto_removed=${DATABASE_URL#postgresql://}
  creds_and_rest="$proto_removed"

  if echo "$creds_and_rest" | grep -q "@"; then
    creds=${creds_and_rest%%@*}
    rest=${creds_and_rest#*@}
    user=${creds%%:*}
    pass=${creds#*:}
    export DB_USERNAME="$user"
    export DB_PASSWORD="$pass"
    export SPRING_DATASOURCE_URL="jdbc:postgresql://${rest}"
  else
    export SPRING_DATASOURCE_URL="jdbc:postgresql://${creds_and_rest}"
  fi
fi

# Default Java options
# file.encoding/sun.jnu.encoding se fuerzan a UTF-8 explícitamente: la imagen base
# (Alpine, sin locales instaladas) no garantiza UTF-8 como charset por defecto en JDK 17
# (JEP 400 "UTF-8 por defecto" solo llega en JDK 18+), lo que podía corromper tildes/eñes.
java \
  -XX:+UseContainerSupport \
  -XX:MaxRAMPercentage=75.0 \
  -Djava.security.egd=file:/dev/./urandom \
  -Dfile.encoding=UTF-8 \
  -Dsun.jnu.encoding=UTF-8 \
  -jar app.jar
