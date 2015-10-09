#!/bin/bash

service_id=$1; shift
store_path=$1; shift

if [[ "${store_path}X" == "X" ]]; then
  echo "USAGE ./bin/backup.sh <service_id> <store_path>"
  exit 1
fi

if [[ "${uri}X" == "X" ]]; then
  echo "Require \$uri for postgresql DB"
  exit 1
fi

mkdir -p $(dirname $store_path)
pg_dump --no-owner --inserts --no-privileges --verbose -f $store_path -F t $uri
