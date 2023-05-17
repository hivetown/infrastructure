#!/bin/bash
# Load env
set -a
. .env
set +a

# Master
# Generate init.sql from template, replacing environment variables with their values
envsubst < templates/master/init.sql > master/init.sql

# Generate mysql.cnf from template, replacing environment variables with their values
envsubst < templates/master/mysql.cnf > master/mysql.cnf

# Slave
# Generate init.sql from template, replacing environment variables with their values
envsubst < templates/slave/init.sql > slave/init.sql

# Generate mysql.cnf from template, replacing environment variables with their values
envsubst < templates/slave/mysql.cnf > slave/mysql.cnf
