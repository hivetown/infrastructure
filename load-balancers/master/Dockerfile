FROM haproxytech/haproxy-alpine:2.7.6

# Install keepalived
RUN apk add --no-cache keepalived

# Copy the configuration files
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY keepalived.conf /etc/keepalived/keepalived.conf
COPY takeover.sh /etc/keepalived/takeover.sh

# Expose the port
# EXPOSE 80 443 1936

# Start the services
CMD ["keepalived", "-f", "/etc/keepalived/keepalived.conf", "-n", "-D", "-l", "-S", "0"]