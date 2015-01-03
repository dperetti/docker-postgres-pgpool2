#!/bin/bash
echo "******CREATING PGPOOL EXTENSIONS******"
gosu postgres postgres --single template1 <<- EOSQL
	CREATE EXTENSION pgpool_regclass;
	CREATE EXTENSION pgpool_recovery;
	CREATE EXTENSION pgpool_adm
EOSQL

gosu postgres postgres --single -jE <<-EOSQL
	CREATE USER "$REPLICATION_USER" REPLICATION LOGIN ENCRYPTED PASSWORD $REPLICATION_PASSWORD;
EOSQL

# postgresql.conf
{ echo; echo "wal_level = hot_standby"; } >> "$PGDATA"/postgresql.conf
{ echo "max_wal_senders = 1"; } >> "$PGDATA"/postgresql.conf
{ echo "max_replication_slots = 1"; } >> "$PGDATA"/postgresql.conf

# pg_hba.conf
{ echo; echo "local replication postgres trust"; } >> "$PGDATA"/pg_hba.conf
{ echo; echo "host replication \"$REPLICATION_USER\" 0.0.0.0/0 md5"; } >> "$PGDATA"/pg_hba.conf



# # Specifies a trigger file whose presence should cause streaming replication to
# # end (i.e., failover).
# trigger_file = '/tmp/pg_failover'
# 
# # Specifies a command to load archive segments from the WAL archive. If
# # wal_keep_segments is a high enough number to retain the WAL segments
# # required for the standby server, this may not be necessary. But
# # a large workload can cause segments to be recycled before the standby
# # is fully synchronized, requiring you to start again from a new base backup.
# #restore_command = 'cp /path_to/archive/%%f "%%p"'
