FROM cfcommunity/postgresql-base:9.3
MAINTAINER Ferran Rodenas & Dr Nic Williams

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

# jq used by backup.sh & restore.sh
ADD http://stedolan.github.io/jq/download/linux64/jq /usr/bin/
RUN chmod 775 /usr/bin/jq

RUN echo "checkpoint_segments = 10\n\
checkpoint_completion_target = 0.9" >> /etc/postgresql/9.3/main/postgresql.conf