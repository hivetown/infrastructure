#!/bin/bash

docker exec -it mysql-db-1 mysql -uroot -phello -e "SHOW SLAVE STATUS\G"