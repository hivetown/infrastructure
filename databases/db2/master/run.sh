#!/bin/bash

docker run --name mysql-db-2 -e MYSQL_ROOT_PASSWORD=hello -d -p 3306:3306 mysql-master-image
