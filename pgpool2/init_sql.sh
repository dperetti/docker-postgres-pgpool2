#!/bin/bash
echo "******CREATING PGPOOL EXTENSIONS******"
gosu postgres postgres --single template1 <<- EOSQL
	CREATE EXTENSION pgpool_regclass;
	CREATE EXTENSION pgpool_recovery;
	CREATE EXTENSION pgpool_adm
EOSQL

# postgresql.conf
{ echo; echo "wal_level = hot_standby"; } >> "$PGDATA"/postgresql.conf
{ echo "max_wal_senders = 5"; } >> "$PGDATA"/postgresql.conf

# pg_hba.conf
{ echo; echo "local replication postgres trust"; } >> "$PGDATA"/pg_hba.conf


# recovery.conf
# { echo "standby_mode = 'off'"; } > "$PGDATA"/recovery.conf
# { echo "primary_conninfo = 'host=$MASTER_HOST port=5432 user=postgres'"; } > "$PGDATA"/recovery.conf
# { echo "primary_slot_name = 'node_a_slot'"; } > "$PGDATA"/recovery.conf
# { echo "restore_command = 'on'"; } > "$PGDATA"/recovery.conf



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
