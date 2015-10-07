BOSH Release for PostgreSQL in Docker container
===============================================

This BOSH release has three use cases:

-	run a single Docker container of a PostgreSQL Docker image on a single BOSH VM
-	run a Cloud Foundry service broker that itself runs containers of PostgreSQL Docker image on a BOSH VM based on user requests
-	embedded PostgreSQL Docker image that could be used by another BOSH release

The PostgreSQL image can be referenced either:

-	from an embebbed/bundled image stored with each BOSH release version
-	from upstream and/or private registries

Spiff deployment templates are included for:

-	bosh-lite/garden
-	bosh-lite/warden (older bosh-lites, deprecated)
-	bosh/aws

[Learn more](https://blog.starkandwayne.com/2015/04/28/embed-docker-into-bosh-releases/) about embedding Docker images in BOSH releases.

Installation
------------

To use this BOSH release, first upload it to your bosh and the `docker` release

```
bosh upload release https://bosh.io/d/github.com/cf-platform-eng/docker-boshrelease
bosh upload release https://bosh.io/d/github.com/cloudfoundry-community/postgresql-docker-boshrelease
```

For the various Usage cases below you will need this git repo's `templates` folder:

```
git clone https://github.com/cloudfoundry-community/postgresql-docker-boshrelease.git
cd postgresql-docker-boshrelease
```

Usage
-----

### Run a single container of PostgreSQL

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment manifest & deploy a single VM:

```
templates/make_manifest warden container embedded
bosh -n deploy
```

This deployment will look like:

```
$ bosh vms postgresql-docker-warden
+------------------------+---------+---------------+--------------+
| Job/index              | State   | Resource Pool | IPs          |
+------------------------+---------+---------------+--------------+
| postgresql_docker_z1/0 | running | small_z1      | 10.244.20.10 |
+------------------------+---------+---------------+--------------+
```

If you want to use the upstream version of the Docker image, reconfigure the deployment manifest:

```
templates/make_manifest warden container upstream
bosh -n deploy
```

To register your Logstash with a Cloud Foundry application on bosh-lite/warden:

```
cf cups postgresql -l syslog://10.244.20.10:514
```

Now bind it to your applications and their STDOUT/STDERR logs will automatically stream to your PostgreSQL.

```
cf bs my-app postgresql
```

### Run a Cloud Foundry service broker for PostgreSQL

For [bosh-lite](https://github.com/cloudfoundry/bosh-lite), you can quickly create a deployment manifest & deploy a single VM that also includes a service broker for Cloud Foundry

```
templates/make_manifest warden broker embedded
bosh -n deploy
```

This deployment will also look like:

```
$ bosh vms postgresql-docker-warden
+------------------------+---------+---------------+--------------+
| Job/index              | State   | Resource Pool | IPs          |
+------------------------+---------+---------------+--------------+
| postgresql_docker_z1/0 | running | small_z1      | 10.244.20.10 |
+------------------------+---------+---------------+--------------+
```

As a Cloud Foundry admin, you can register the broker and the service it provides:

```
cf create-service-broker postgresql-docker containers containers http://10.244.20.10
cf enable-service-access postgresql93
cf marketplace
```

If you want to use the upstream version of the Docker image, reconfigure the deployment manifest:

```
templates/make_manifest warden container upstream
bosh -n deploy
```

### Using Cloud Foundry Service Broker

Users can now provision PostgreSQL services and bind them to their apps.

```
cf cs postgresql93 free my-pg
cf bs my-app my-pg
```

### Versions & configuration

The version of PostgreSQL is determined by the Docker image bundled with the release being used. The source for building the Docker image is in the `images/postgresql` folder of this repo. See below for instructions.

### Development of postgresql configuration

To push new ideas/new PostgreSQL versions to an alternate Docker Hub image name:

```
cd images/postgresql-dev
export DOCKER_USER=<your user>
docker build -t $DOCKER_USER/postgresql .
docker push $DOCKER_USER/postgresql
```

This will create a new Docker image, based upon the upstream `cfcommunity/postgresql:9.4`.

You can now try out new postgresql configuration in `images/postgresql-dev/etc/postgresql/postgresql.conf` and re-build/push the image quickly.

You can now test them using `upstream` templates.

Create an override YAML file, say `my-docker-image.yml`

```yaml
---
meta:
  postgresql_images:
    image: USERNAME/postgresql
    tag: latest
```

To deploy this change into BOSH, add the `my-docker-image.yml` file to the end of the `make_manifest` command:

```
./templates/make_manifest warden container upstream my-docker-image.yml
bosh deploy
```

### Development of releases

To recreate the Docker image that hosts Logstash & Elastic Search and push it upstream:

```
cd image
docker build -t cfcommunity/postgresql:9.4 .
```

To package the Docker image back into this release:

```
bosh-gen package postgresql --docker-image cfcommunity/postgresql:9.4
bosh upload blobs
```

To create new development releases and upload them:

```
bosh create release --force && bosh -n upload release
```

### Final releases

To share final releases, which include the `cfcommunity/postgresql:9.4` docker image embedded:

```
bosh create release --final
```

By default the version number will be bumped to the next major number. You can specify alternate versions:

```
bosh create release --final --version 2.1
```
