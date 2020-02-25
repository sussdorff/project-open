#!/bin/sh
# wait-for-postgres.sh

set -e

PGPASSWORD = $(cat "/run/secrets/psql_password")
PGUSER = $(cat "/run/secrets/psql_user")
until psql -h "postgres" -U $PGUSER -c '\q'; do
  >&2 echo "Postgres is unavailable - sleeping"
  sleep 1
done

>&2 echo "Postgres is up - Starting OpenACS Now"

/usr/local/ns/bin/nsd -f -u nsadmin -g nsadmin -t /usr/local/ns/conf/openacs-config.tcl
