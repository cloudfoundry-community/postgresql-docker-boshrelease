FROM frodenas/ubuntu
MAINTAINER Ferran Rodenas & Dr Nic Williams

# Install PostgreSQL 9.3
ENV PG_VERSION=9.3
RUN DEBIAN_FRONTEND=noninteractive \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    echo 'deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main' > /etc/apt/sources.list.d/pgdg.list && \
    apt-get update && \
    apt-get install -y --force-yes \
      postgresql-${PG_VERSION} \
      postgresql-client-${PG_VERSION} \
      postgresql-contrib-${PG_VERSION} && \
    service postgresql stop && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
