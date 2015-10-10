Examples
--------

### Running backup.sh

```
dburi=postgres://user:pass@pellefant.db.elephantsql.com:5432/database
server_major_version=$(psql $dburi -c "show server_version;" | head -n3 | tail -n1 | awk '{print $1}' | head -c 3)

backupdir=/tmp/backups; mkdir -p $backupdir
image=cfcommunity/postgresql:$server_major_version
echo "{\"credentials\": {\"uri\": \"${dburi}\"}}" | \
  docker run -i \
    --entrypoint /scripts/backup.sh \
    -v ${backupdir}:/data:rw \
    $image someid /data/mybackup/mybackup.tgz
```
