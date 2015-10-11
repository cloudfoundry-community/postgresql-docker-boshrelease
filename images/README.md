Examples
--------

### Running backup.sh

```
dburi=postgres://user:pass@pellefant.db.elephantsql.com:5432/database
server_major_version=$(psql $dburi -c "show server_version;" | head -n3 | tail -n1 | awk '{print $1}' | head -c 3)

image=cfcommunity/postgresql:$server_major_version
echo "{\"credentials\": {\"uri\": \"${dburi}\"}}" | \
  docker run -i \
    --entrypoint /scripts/backup.sh \
    -v /tmp/backups:/data:rw \
    $image someid /data/mybackup/mybackup.tgz
```

The `mybackup.tgz` file will be at `/tmp/backups/mybackup/mybackup.tgz` on the machine running the docker daemon.

For laptops running `docker-machine`, you will first need to SSH into this VM:

```
laptop$ docker-machine ssh default

docker@default:~$ ls -al /tmp/backups/mybackup/mybackup.tgz
-rw-r--r--    1 root     root         20992 Oct 11 05:37 /tmp/backups/mybackup/mybackup.tgz
```
