#!/bin/bash
echo "******CREATING PGPOOL EXTENSIONS******"
gosu postgres postgres --single template1 <<- EOSQL
	CREATE EXTENSION pgpool_regclass;
	CREATE EXTENSION pgpool_recovery;
	CREATE EXTENSION pgpool_adm
EOSQL

cat > "$PGDATA"/pg_hba.conf <<EOS
# TYPE  DATABASE        USER            ADDRESS                 METHOD
# "local" is for Unix domain socket connections only
local   all             all                                     trust
# IPv4 local connections:
host    all             all             127.0.0.1/32            trust
# IPv6 local connections:
host    all             all             ::1/128                 trust

# Allow anyone to connect remotely so long as they have a valid username and 
# password.
host all all 0.0.0.0/0 md5
EOS

# postgresql.conf
{ echo; echo "wal_level = hot_standby"; } >> "$PGDATA"/postgresql.conf
{ echo "max_wal_senders = 1"; } >> "$PGDATA"/postgresql.conf
{ echo "max_replication_slots = 1"; } >> "$PGDATA"/postgresql.conf

# pg_hba.conf
{ echo; echo "local replication postgres trust"; } >> "$PGDATA"/pg_hba.conf
{ echo; echo "host replication \"$REPLICATION_USER\" 0.0.0.0/0 md5"; } >> "$PGDATA"/pg_hba.conf

gosu postgres postgres --single -jE <<-EOSQL
	CREATE USER "$REPLICATION_USER" REPLICATION LOGIN ENCRYPTED PASSWORD '$REPLICATION_PASSWORD';
	SELECT * FROM pg_create_physical_replication_slot('$REPLICATION_SLOT');
EOSQL



# # Specifies a trigger file whose presence should cause streaming replication to
# # end (i.e., failover).
# trigger_file = '/tmp/pg_failover'
# 