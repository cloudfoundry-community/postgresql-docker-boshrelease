Examples
--------

### Running backup.sh

```
dburi=postgres://user:pass@pellefant.db.elephantsql.com:5432/database
backupdir=/tmp/backups; mkdir -p $backupdir
image=cfcommunity/postgresql:9.4
echo "{\"credentials\": {\"uri\": \"${dburi}\"}}" | \
  docker run --add-host=db:$hostip -i \
    -v ${backupdir}:/data:rw \
    --entrypoint /scripts/backup.sh \
    $image someid /data/mybackup/mybackup.tgz
```
