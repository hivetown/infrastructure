#!/bin/bash

docker exec -it mysql-db-2 mysql -uroot -phello -e "SHOW MASTER STATUS\G"