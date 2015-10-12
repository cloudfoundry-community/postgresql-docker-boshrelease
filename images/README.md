Examples
--------

### Running backup.sh

```
mydb=my-target-db
cf create-service-key $mydb backup-binding
cf service-key $mydb backup-binding
binding_guid=$(cf service-key $mydb backup-binding --guid)
from_dburi=$(cf curl /v2/service_keys/${binding_guid} | jq -r .entity.credentials.uri)

server_major_version=$(psql $dburi -c "show server_version;" | head -n3 | tail -n1 | awk '{print $1}' | head -c 3)

image=cfcommunity/postgresql:$server_major_version # or newer
echo "{\"credentials\": {\"uri\": \"${from_dburi}\"}}" | \
  docker run -i \
    --entrypoint /scripts/backup.sh \
    -v /tmp/backups:/data:rw \
    $image someid /data/mybackup/backup.dump
```

The `backup.dump` file will be at `/tmp/backups/mybackup/backup.dump` on the machine running the docker daemon.

### Preparing a new DB for restore

```
cf create-service elephantsql turtle restore-mydb
cf create-service-key restore-mydb restore-binding
cf service-key restore-mydb restore-binding
binding_guid=$(cf service-key restore-mydb restore-binding --guid)
to_dburi=$(cf curl /v2/service_keys/${binding_guid} | jq -r .entity.credentials.uri)
```

### Running restore.sh

```
server_major_version=$(psql $dburi -c "show server_version;" | head -n3 | tail -n1 | awk '{print $1}' | head -c 3)

image=cfcommunity/postgresql:$server_major_version
echo "{\"credentials\": {\"uri\": \"${to_dburi}\"}}" | \
  docker run -i \
    --entrypoint /scripts/restore.sh \
    -v /tmp/backups:/data:rw \
    $image /data/mybackup/backup.dump
```
