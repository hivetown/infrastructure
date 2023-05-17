#!/bin/bash
# Error if .env does not exist
if [ ! -f .env ]; then
  echo "ERROR: .env file not found. Please create it from .env.example"
  exit 1
fi

# Populate environment variables from local .env
set -a
. .env
set +a

# Generate keepalived.master.conf from template, replacing environment variables with their values
export STATE=MASTER
export PRIORITY=100
envsubst < keepalived.template.conf > keepalived.master.conf

# Generate keepalived.backup.conf from template, replacing environment variables with their values
export STATE=BACKUP
export PRIORITY=50
envsubst < keepalived.template.conf > keepalived.backup.conf
