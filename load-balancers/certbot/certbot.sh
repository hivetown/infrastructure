#!/bin/bash
echo "Certbot running..."
certbot --tls-sni-01-port=8888

echo "Certbot finished."
