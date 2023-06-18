#!/bin/bash
# Load env
set -a
. .env
set +a

envsubst < init_slave.template.sql > init_slave.sql
envsubst < my.template.cnf > my.cnf
