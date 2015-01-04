#!/bin/bash

echo "$PRIMARY_HOST:$PRIMARY_PORT:replication:$REPLICATION_USER:$REPLICATION_PASSWORD" > .pgpass
chmod 0600 .pgpass
export PGPASSFILE=`pwd`/.pgpass

echo "Creating base backup"
# can't use gosu here because for some reason pgpass is then ignored...
pg_basebackup -h $PRIMARY_HOST -p $PRIMARY_PORT -U "$REPLICATION_USER" --no-password -x -D "$PGDATA" --progress
# ...so we chown afterwards instead
chown -RL postgres:postgres "$PGDATA"
chmod 0700 "$PGDATA"

#psql -h $PRIMARY_HOST -p $PRIMARY_PORT -U $REPLICATION_USER --no-password -c "SELECT * FROM pg_create_physical_replication_slot('$REPLICATION_SLOT')"

# postgresql.conf

# Enable read-only queries on the standby server
{ echo "hot_standby = on"; } >> "$PGDATA"/postgresql.conf

# recovery.conf
{ echo "standby_mode = 'on'"; } > "$PGDATA"/recovery.conf
{ echo "primary_conninfo = 'host=$PRIMARY_HOST port=$PRIMARY_PORT user=$REPLICATION_USER password=$REPLICATION_PASSWORD'"; } >> "$PGDATA"/recovery.conf
{ echo "primary_slot_name = '$REPLICATION_SLOT'"; } >> "$PGDATA"/recovery.conf

# Launch postgres
exec gosu postgres postgres
