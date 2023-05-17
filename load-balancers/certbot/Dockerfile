FROM alpine:3.16.5

RUN apk add --no-cache certbot

COPY certbot.sh /app/certbot.sh

CMD ["/app/certbot.sh"]
