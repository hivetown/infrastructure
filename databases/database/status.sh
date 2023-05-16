#!/bin/bash
# Load env
set -a
. .env
set +a

docker exec -it $DOCKER_CONTAINER mysql -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW MASTER STATUS\G"