#!/bin/bash

# USAGE echo '{"credentials": {"uri": "postgresql://drnic@localhost:5432/booktown-restore"}}' |
#   ./restore.sh /path/to/backup.tgz /tmp/restore
exec 1>&2 # redirect all output to stderr for logging

backup_path=$1; shift
tmp_dir=${1:-/tmp}; shift

if [[ "${backup_path}X" == "X" ]]; then
  echo "USAGE ./bin/restore.sh <backup_path> [<tmp_dir>]"
  exit 1
fi

set -e
set -x

payload=$(mktemp /tmp/backup-in.XXXXXX)
cat > $payload <&0

uri=$(jq -r '.credentials.uri // ""' < $payload)

if [[ "${uri}X" == "X" ]]; then
  echo "STDIN requires .credentials.uri for postgresql DB"
  exit 1
fi

unpack_dir=$tmp_dir/backup
rm -rf $unpack_dir
mkdir -p $unpack_dir
cd $unpack_dir

echo "unpacking tarball"
ls /data
ls /data/mybackup
tar xf $backup_path

# TODO: should restore.sh cleanup, or if data is on diff volumes then can be managed externally?
# echo "deleting tarball to save space"
# rm -rf $backup_path

restore_sql=$unpack_dir/restore.sql
if [[ ! -f $restore_sql ]]; then
  echo "ERROR: unpacked backup is missing restore.sql"
  exit 1
fi

sed -i'' -e 's/\$\$PATH\$\$/./g' $restore_sql
# cat $restore_sql | grep PATH

echo "importing to psql $PG_VERSION"
psql $uri -f $restore_sql

rm -rf $unpack_dir
