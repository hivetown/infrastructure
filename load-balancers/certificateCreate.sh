#!/bin/bash
# Load env
set -a
. .env
set +a

LOCAL_DIR='./letsencrypt'

# Run certbot to create certificates
docker run --rm -it \
    --name certbot \
    -p 8888:80 \
    --volume $LOCAL_DIR:/etc/letsencrypt \
    certbot/certbot \
        certonly \
            --non-interactive --standalone \
            --agree-tos --no-eff-email \
            -d $CERTBOT_DOMAINS --email $CERTBOT_EMAIL 
            # --force-renew --test-cert # Uncomment for testing ONLY

# Get main domain
MAIN_DOMAIN=`echo $CERTBOT_DOMAINS | cut -d',' -f1`

# Create PEM file for HAProxy
cat $LOCAL_DIR/live/$MAIN_DOMAIN/fullchain.pem $LOCAL_DIR/live/$MAIN_DOMAIN/privkey.pem > $LOCAL_DIR/live/$MAIN_DOMAIN/$MAIN_DOMAIN.pem
