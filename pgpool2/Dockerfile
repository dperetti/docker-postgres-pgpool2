# Extends https://github.com/docker-library/postgres/blob/c9d9f4c1a0d33a161fefda666f041ef0dc4dc9f8/9.4/Dockerfile
FROM postgres:9.4 

RUN apt-get update

# We'll need postgresql-server-dev-9.4 to build pgpool extensions,
# apache and php to run pgpoolAdmin
RUN apt-get install -y postgresql-server-dev-9.4 apache2 libapache2-mod-php5 curl build-essential
RUN curl -L -o pgpool-II-3.4.0.tar.gz http://www.pgpool.net/download.php?f=pgpool-II-3.4.0.tar.gz 
RUN tar zxvf pgpool-II-3.4.0.tar.gz

# Build pgpool2
WORKDIR /pgpool-II-3.4.0
RUN ./configure
RUN make
RUN make install

# Build pgpool2 extensions for postgres
WORKDIR /pgpool-II-3.4.0/src/sql
RUN make
RUN make install

RUN ldconfig

# clean up
RUN rm -rf /pgpool-II-3.4.0 & rm /pgpool-II-3.4.0.tar.gz

# Install pgpoolAdmin
WORKDIR /var/www
RUN rm index.html
RUN curl -O http://www.pgpool.net/mediawiki/images/pgpoolAdmin-3.4.0.tar.gz
RUN tar --strip-components=1 -zxvf pgpoolAdmin-3.4.0.tar.gz
ENV APACHE_RUN_USER www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR /var/log/apache2
ENV PG_REPL_USER docker
ENV PG_REPL_PASS docker
ENV PCP_USER docker
ENV PCP_PASS docker
ADD ./pgmgt.conf.php /var/www/conf/
ADD ./pool_hba.conf /usr/local/etc/
ADD setup.sh /var/www/
RUN sh ./setup.sh

# pgpool
EXPOSE 9999
# pgpoolAdmin
EXPOSE 80

# Add pgpool extension to the database template
ADD init_sql.sh /docker-entrypoint-initdb.d/

# Add streaming replication script
RUN mkdir /replication
COPY stream_from_master.sh /replication/
RUN chmod +x /replication/stream_from_master.sh
ENV REPLICATION_USER replicator
ENV REPLICATION_PASSWORD replicator