BOSH Release for PostgreSQL in Docker container
===============================================

This BOSH release has three use cases:

-	run a single Docker container of a PostgreSQL Docker image on a single BOSH VM
-	run a Cloud Foundry service broker that itself runs containers of PostgreSQL Docker image on a BOSH VM based on user requests
-	embedded PostgreSQL Docker image that could be used by another BOSH release

As a Cloud Foundry service broker, there are two version of PostgreSQL that can be offered:

```
$ cf marketplace
Getting services from marketplace in org system / space dev as admin...
OK

service        plans   description
postgresql93   free    postgresql 9.3 service for application development and testing
postgresql94   free    postgresql 9.4 service for application development and testing
```

NOTE: if you're deploying the broker for the first time, it is suggested to only offer the latest database to minimize the operations upset of deprecating and disabling the older one in the future.

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

The version of PostgreSQL is determined by the Docker image bundled with the release being used. The source for building the Docker images is in the `images/` folders of this repo. See below for instructions.

### Development of postgresql configuration

To push new ideas/new PostgreSQL versions to an alternate Docker Hub image name:

```
cd images/postgresql95
export DOCKER_USER=<your user>
docker build -t $DOCKER_USER/postgresql .
docker push $DOCKER_USER/postgresql:9.5
```

This will create a new Docker image, based upon the upstream `cfcommunity/postgresql-base:9.5`.

Create an override YAML file, say `my-docker-image.yml`

```yaml
---
meta:
  postgresql_images:
    image: USERNAME/postgresql
    tag: 9.5
```

To deploy this change into BOSH, add the `my-docker-image.yml` file to the end of the `make_manifest` command:

```
./templates/make_manifest warden container upstream my-docker-image.yml
bosh deploy
```
