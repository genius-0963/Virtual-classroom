#!/usr/bin/env bash
# ==============================================================================
# Virtual Classroom — Let's Encrypt SSL/HTTPS Setup for AWS EC2 & Lightsail
# ==============================================================================
set -euo pipefail

if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root or with sudo: sudo ./setup-ssl.sh <domain> <email>"
    exit 1
fi

DOMAIN="${1:-}"
EMAIL="${2:-}"

if [ -z "$DOMAIN" ] || [ -z "$EMAIL" ]; then
    echo "Usage: sudo ./setup-ssl.sh <your-domain.com> <your-email@example.com>"
    echo "Example: sudo ./setup-ssl.sh vclass.myschool.edu admin@myschool.edu"
    exit 1
fi

echo "=========================================================="
echo " Setting up Let's Encrypt SSL for: $DOMAIN"
echo " Notification Email: $EMAIL"
echo "=========================================================="

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# 1. Install Certbot
apt-get update -y
apt-get install -y certbot

# 2. Temporarily stop Nginx so certbot can bind port 80 to issue certificate
echo "[+] Temporarily stopping Nginx container..."
docker stop virtual_classroom_nginx || true

# 3. Issue certificate using certbot standalone mode
echo "[+] Requesting Let's Encrypt SSL Certificate..."
certbot certonly --standalone \
    -d "$DOMAIN" \
    --non-interactive \
    --agree-tos \
    -m "$EMAIL"

# 4. Generate nginx SSL configuration from template
echo "[+] Generating Nginx SSL configuration..."
export DOMAIN
envsubst '${DOMAIN}' < nginx/ssl.conf.template > nginx/default.conf

# 5. Update docker-compose.prod.yml if port 443 is not mapped
if ! grep -q '443:443' docker-compose.prod.yml; then
    sed -i '/ports:/a \      - "443:443"' docker-compose.prod.yml
fi

# Ensure Let's Encrypt cert directory is mounted into Nginx container
if ! grep -q '/etc/letsencrypt' docker-compose.prod.yml; then
    sed -i '/volumes:/a \      - /etc/letsencrypt:/etc/letsencrypt:ro' docker-compose.prod.yml
fi

# 6. Restart production docker stack
echo "[+] Restarting Docker stack with SSL enabled..."
docker compose -f docker-compose.prod.yml up -d

# 7. Configure automated renewal hook in crontab
CRON_RENEW="0 2 * * * certbot renew --quiet --pre-hook 'docker stop virtual_classroom_nginx' --post-hook 'docker start virtual_classroom_nginx'"
(crontab -l 2>/dev/null | grep -v "certbot renew" ; echo "$CRON_RENEW") | crontab -

echo "=========================================================="
echo " [✓] HTTPS SSL Setup Completed Successfully!"
echo " Access your secure portal at: https://$DOMAIN"
echo "=========================================================="
