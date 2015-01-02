#!/bin/bash
echo "******CREATING PGPOOL EXTENSIONS******"
gosu postgres postgres --single template1 <<- EOSQL
	CREATE EXTENSION pgpool_regclass;
	CREATE EXTENSION pgpool_recovery;
	CREATE EXTENSION pgpool_adm
EOSQL