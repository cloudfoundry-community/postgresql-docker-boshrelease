FROM frodenas/ubuntu
MAINTAINER Ferran Rodenas & Dr Nic Williams

# Install PostgreSQL 9.5
ENV PG_VERSION=9.5
ENV POSTGIS_VERSION=2.2
RUN DEBIAN_FRONTEND=noninteractive \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main ${PG_VERSION}" > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --force-yes \
      postgresql-${PG_VERSION} \
      postgresql-client-${PG_VERSION} \
      postgresql-contrib-${PG_VERSION} \
      postgresql-${PG_VERSION}-postgis-${POSTGIS_VERSION} \
      postgresql-${PG_VERSION}-pgrouting \
      postgis && \
    service postgresql stop && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
