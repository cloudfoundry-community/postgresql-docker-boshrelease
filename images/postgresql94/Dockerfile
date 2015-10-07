FROM frodenas/ubuntu
MAINTAINER Ferran Rodenas & Dr Nic Williams

# Install PostgreSQL 9.4
RUN DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --force-yes \
    postgresql-9.4 postgresql-client-9.4 postgresql-contrib-9.4 && \
    service postgresql stop && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Add scripts
ADD scripts /scripts
RUN chmod +x /scripts/*.sh
RUN touch /.firstrun

# Command to run
ENTRYPOINT ["/scripts/run.sh"]
CMD [""]

# Expose listen port
EXPOSE 5432

# Expose our data directory
VOLUME ["/data"]
