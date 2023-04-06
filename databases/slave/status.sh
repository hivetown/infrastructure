#!/bin/bash

sudo docker exec -it mysql-slave-hivetown mysql -uroot -phello -e "SHOW SLAVE STATUS\G"