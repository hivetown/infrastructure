#!/bin/bash
docker exec -it mysql-hivetown mysql -e "SHOW MASTER STATUS\G"
