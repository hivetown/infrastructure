#!/bin/bash

sudo docker exec -it mysql-db-1 mysql -uroot -phello -e "SHOW MASTER STATUS\G"