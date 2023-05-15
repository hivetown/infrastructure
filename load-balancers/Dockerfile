# Use the official HAProxy Alpine image
FROM haproxytech/haproxy-alpine:2.6.10

RUN apk add --no-cache bash

COPY ./dataplaneapi /usr/bin/dataplaneapi
RUN chmod +x /usr/bin/dataplaneapi

# Copy the configuration files
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg

# Expose the ports to the host
EXPOSE 80 443
