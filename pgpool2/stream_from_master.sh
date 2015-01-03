#!/bin/bash

chown -R postgres "$PGDATA"
ls -la "$PGDATA"
gosu postgres pg_basebackup -h $MASTER_HOST -U postgres -x -D "$PGDATA" --progress
chmod 0700 "$PGDATA"
# postgresql.conf

# Enable read-only queries on the standby server
{ echo "hot_standby = on"; } >> "$PGDATA"/postgresql.conf

## recovery.conf
{ echo "standby_mode = 'on'"; } > "$PGDATA"/recovery.conf
{ echo "primary_conninfo = 'host=$PRIMARY_HOST port=5432 user=$REPLICATION_USER password=$REPLICATION_PASSWORD'"; } >> "$PGDATA"/recovery.conf
# { echo "primary_slot_name = 'node_a_slot'"; } >> "$PGDATA"/recovery.conf

#gosu postgres psql -h $MASTER_HOST -U postgres
exec gosu postgres postgres
