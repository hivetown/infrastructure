#!/bin/bash

echo "MASTER" > /etc/keepalived/state

# Start HAProxy
haproxy -f /usr/local/etc/haproxy/haproxy.cfg