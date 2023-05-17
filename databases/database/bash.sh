#!/bin/bash
# Load env
set -a
. .env
set +a

docker exec -it $DOCKER_CONTAINER bash
