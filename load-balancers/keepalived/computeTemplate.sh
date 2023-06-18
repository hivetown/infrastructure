#!/bin/bash
# Load env
set -a
. .env
set +a

# Generate keepalived.conf from template, replacing environment variables with their values
envsubst < keepalived.template.conf > keepalived.conf
