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

# Generate keepalived.conf from template, replacing environment variables with their values
envsubst < keepalived.template.conf > keepalived.conf
