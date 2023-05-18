#!/bin/bash
# Load env
set -a
. .env
set +a

export STATE=MASTER
export PRIORITY=100
envsubst < keepalived.template.conf > keepalived.master.conf

export STATE=BACKUP
export PRIORITY=50
envsubst < keepalived.template.conf > keepalived.backup.conf