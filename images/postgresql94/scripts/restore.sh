#!/bin/bash

backup_path=$1; shift
tmp_dir=$1; shift

if [[ "${tmp_dir}X" == "X" ]]; then
  echo "USAGE ./bin/restore.sh <backup_path> <tmp_dir>"
  exit 1
fi

if [[ "${uri}X" == "X" ]]; then
  echo "Require \$uri for postgresql DB"
  exit 1
fi

unpack_dir=$tmp_dir/backup
rm -rf $unpack_dir
mkdir -p $unpack_dir
cd $unpack_dir
tar xfz $backup_path

restore_sql=$unpack_dir/restore.sql
if [[ ! -f $restore_sql ]]; then
  echo "ERROR: unpacked backup is missing restore.sql"
  exit 1
fi

sed -i '' -e 's/\$\$PATH\$\$/./g' $restore_sql
cat $restore_sql | grep PATH

psql $uri -f $restore_sql

rm -rf $unpack_dir
