#!/bin/bash
# Load env
set -a
. .env
set +a

envsubst < haproxy.template.cfg > haproxy.cfg
