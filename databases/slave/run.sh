#!/bin/bash

docker run --name mysql-slave-hivetown -e MYSQL_ROOT_PASSWORD=hello -d -p 3306:3306 mysql-slave-image