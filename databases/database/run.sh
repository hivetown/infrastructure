#!/bin/bash
# Load env
set -a
. .env
set +a

docker run --name $DOCKER_CONTAINER -d -p 3306:3306 $DOCKER_IMAGE
