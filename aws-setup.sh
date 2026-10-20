#!/usr/bin/env bash
# ==============================================================================
# Virtual Classroom — AWS Automated Provisioning & Deployment Script
# Supports: Ubuntu 22.04 LTS, Ubuntu 24.04 LTS (AWS EC2 & AWS Lightsail)
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo " Starting AWS Deployment: Virtual Classroom Stack"
echo "=========================================================="

# 1. Verify root / sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root or with sudo: sudo ./aws-setup.sh"
    exit 1
fi

# 2. Configure Swap Space (Crucial for JVM & MySQL stability on AWS budget tiers)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [ "$TOTAL_RAM_KB" -lt 3000000 ]; then
    if [ ! -f /swapfile ]; then
        echo "[+] System RAM is under 3GB ($((TOTAL_RAM_KB / 1024)) MB). Allocating 2GB swap..."
        fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        if ! grep -q '/swapfile' /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        echo "[✓] 2GB swap successfully configured."
    else
        echo "[✓] Swap file already present."
    fi
fi

# 3. Update APT repositories and install prerequisites
echo "[+] Updating system packages..."
apt-get update -y
apt-get install -y ca-certificates curl gnupg lsb-release git ufw

# 4. Install official Docker Engine & Docker Compose plugin if not already installed
if ! command -v docker &> /dev/null; then
    echo "[+] Installing Docker Engine & Compose plugin..."
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    systemctl enable docker
    systemctl start docker
    echo "[✓] Docker installed successfully: $(docker --version)"
else
    echo "[✓] Docker is already installed: $(docker --version)"
fi

# 5. Determine application directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# 6. Configure environment (.env)
if [ ! -f .env ]; then
    echo "[+] Generating production .env file with secure randomized passwords..."
    GEN_ROOT_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24)
    GEN_APP_PASS=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 24)

    cat <<EOF > .env
# Database Configuration
MYSQL_ROOT_PASSWORD=${GEN_ROOT_PASS}
MYSQL_DATABASE=project
MYSQL_USER=vclass_user
MYSQL_PASSWORD=${GEN_APP_PASS}

# Application Database Connection
DB_HOST=db
DB_PORT=3306
DB_USER=vclass_user
DB_PASSWORD=${GEN_APP_PASS}
DB_NAME=project

# Port Configuration
WEB_PORT=8080
HTTP_PORT=80
EOF
    chmod 600 .env
    echo "[✓] Created .env with generated database secrets."
else
    echo "[✓] Existing .env detected."
fi

# 7. Configure basic host firewall (UFW)
echo "[+] Configuring firewall (UFW)..."
ufw allow 22/tcp || true
ufw allow 80/tcp || true
ufw allow 443/tcp || true
ufw --force enable || true

# 8. Deploy Production Docker Stack
echo "[+] Building and launching production containers..."
docker compose -f docker-compose.prod.yml down --remove-orphans || true
docker compose -f docker-compose.prod.yml up -d --build

# 9. Configure daily automated backup cron job
BACKUP_SCRIPT="$REPO_DIR/backup-db.sh"
chmod +x "$BACKUP_SCRIPT"
CRON_JOB="0 3 * * * $BACKUP_SCRIPT >> $REPO_DIR/backups/backup.log 2>&1"
(crontab -l 2>/dev/null | grep -v "backup-db.sh" ; echo "$CRON_JOB") | crontab -
echo "[✓] Configured automated daily database backup at 03:00 AM."

# 10. Health check verification
echo ""
echo "[+] Waiting for Virtual Classroom to respond on http://localhost:80..."
MAX_RETRIES=30
COUNT=0
HEALTHY=false

while [ $COUNT -lt $MAX_RETRIES ]; do
    if curl -s -f http://localhost:80/ > /dev/null 2>&1; then
        HEALTHY=true
        break
    fi
    COUNT=$((COUNT + 1))
    printf "."
    sleep 3
done
echo ""

PUBLIC_IP=$(curl -s https://checkip.amazonaws.com || curl -s https://ifconfig.me || echo "YOUR_SERVER_IP")

if [ "$HEALTHY" = true ]; then
    echo "=========================================================="
    echo "  Virtual Classroom successfully deployed on AWS!"
    echo "=========================================================="
    echo " Public Access URL:    http://${PUBLIC_IP}"
    echo " Admin Login:          http://${PUBLIC_IP}/admin_login.jsp"
    echo " Faculty Login:        http://${PUBLIC_IP}/faculty_login.jsp"
    echo " Student Login:        http://${PUBLIC_IP}/student_login.jsp"
    echo " Containers:           docker compose -f docker-compose.prod.yml ps"
    echo " Backup Utility:       ./backup-db.sh"
    echo "=========================================================="
else
    echo "[!] Stack launched but application health check timed out."
    echo "[!] Inspect container logs: docker compose -f docker-compose.prod.yml logs"
fi
