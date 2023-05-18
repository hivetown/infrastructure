#!/bin/bash
# Load env
set -a
. .env
set +a

envsubst < init_master.template.sql > init_master.sql
envsubst < my.template.cnf > my.cnf
