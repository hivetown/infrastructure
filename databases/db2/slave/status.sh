#!/bin/bash

docker exec -it mysql-hivetown mysql -e "SHOW SLAVE STATUS\G"