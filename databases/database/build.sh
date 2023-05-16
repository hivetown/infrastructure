#!/bin/bash
# Load env
set -a
. .env
set +a

docker build -t $DOCKER_IMAGE master/.
