Examples
--------

### Running backup.sh

```
dburi=postgres://user:pass@pellefant.db.elephantsql.com:5432/database
server_version=$(psql $dburi -c "show server_version;" | head -n3 | tail -n1 | awk '{print $1}')
major_version="$(echo $server_version | head -c 3)"

backupdir=/tmp/backups; mkdir -p $backupdir
image=cfcommunity/postgresql:$major_version
echo "{\"credentials\": {\"uri\": \"${dburi}\"}}" | \
  docker run --add-host=db:$hostip -i \
    -v ${backupdir}:/data:rw \
    --entrypoint /scripts/backup.sh \
    $image someid /data/mybackup/mybackup.tgz
```
