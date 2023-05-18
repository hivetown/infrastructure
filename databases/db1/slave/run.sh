#!/bin/bash
docker run --name mysql-hivetown --env-file=/home/romul/master/.env -d -p 3306:3306 mysql-slave-image
