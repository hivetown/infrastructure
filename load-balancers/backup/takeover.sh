#!/bin/bash

echo "BACKUP" > /etc/keepalived/state

# Stop HAProxy
pkill haproxy