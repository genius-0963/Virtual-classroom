#!/usr/bin/env bash
# ==============================================================================
# Virtual Classroom — Oracle Cloud (OCI) Always Free Automated Setup Script
# Supports: Ubuntu (22.04/24.04) and Oracle Linux (8/9) on x86_64 & ARM64 (Ampere A1)
# ==============================================================================
set -euo pipefail

echo "=========================================================="
echo " Oracle Cloud (OCI) Always Free Deployment"
echo " Virtual Classroom Multi-Tier Stack"
echo "=========================================================="

# 1. Verify root / sudo privileges
if [ "$EUID" -ne 0 ]; then
    echo "[!] Please run as root or with sudo: sudo ./oci-setup.sh"
    exit 1
fi

# Detect OS
OS_FAMILY="unknown"
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS_FAMILY="$ID"
fi
echo "[+] Detected OS: $OS_FAMILY ($NAME)"

# 2. Configure Swap Memory if RAM is under 3GB (e.g. AMD Micro instances)
TOTAL_RAM_KB=$(grep MemTotal /proc/meminfo | awk '{print $2}')
if [ "$TOTAL_RAM_KB" -lt 3000000 ]; then
    if [ ! -f /swapfile ]; then
        echo "[+] System RAM is $((TOTAL_RAM_KB / 1024)) MB (< 3GB). Allocating 2GB swap space..."
        fallocate -l 2G /swapfile || dd if=/dev/zero of=/swapfile bs=1M count=2048
        chmod 600 /swapfile
        mkswap /swapfile
        swapon /swapfile
        if ! grep -q '/swapfile' /etc/fstab; then
            echo '/swapfile none swap sw 0 0' >> /etc/fstab
        fi
        echo "[✓] Swap configured successfully."
    fi
else
    echo "[✓] System has ample RAM ($((TOTAL_RAM_KB / 1024)) MB). Skipping swap allocation."
fi

# 3. Configure OS Firewall (Critical for OCI instances)
# Oracle Cloud images enforce strict host-level iptables/firewalld that block HTTP(80)/HTTPS(443) by default.
echo "[+] Configuring host firewall for ports 80 & 443..."
if command -v ufw &> /dev/null; then
    ufw allow 22/tcp || true
    ufw allow 80/tcp || true
    ufw allow 443/tcp || true
    ufw --force enable || true
fi

if command -v iptables &> /dev/null; then
    iptables -I INPUT 6 -p tcp --dport 80 -m state --state NEW,ESTABLISHED -j ACCEPT 2>/dev/null || \
    iptables -I INPUT -p tcp --dport 80 -j ACCEPT 2>/dev/null || true
    iptables -I INPUT 6 -p tcp --dport 443 -m state --state NEW,ESTABLISHED -j ACCEPT 2>/dev/null || \
    iptables -I INPUT -p tcp --dport 443 -j ACCEPT 2>/dev/null || true
fi

if command -v firewall-cmd &> /dev/null; then
    firewall-cmd --zone=public --permanent --add-port=80/tcp || true
    firewall-cmd --zone=public --permanent --add-port=443/tcp || true
    firewall-cmd --reload || true
fi

# 4. Install Docker & Docker Compose
if ! command -v docker &> /dev/null; then
    echo "[+] Installing Docker..."
    if [[ "$OS_FAMILY" == "ubuntu" || "$OS_FAMILY" == "debian" ]]; then
        apt-get update -y
        apt-get install -y ca-certificates curl gnupg lsb-release git iptables-persistent netfilter-persistent
        install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        chmod a+r /etc/apt/keyrings/docker.asc
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
        apt-get update -y
        apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        netfilter-persistent save || true
    elif [[ "$OS_FAMILY" == "ol" || "$OS_FAMILY" == "rhel" || "$OS_FAMILY" == "centos" ]]; then
        yum install -y yum-utils git curl
        yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        yum install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    fi

    systemctl enable docker
    systemctl start docker
    echo "[✓] Docker installed: $(docker --version)"
else
    echo "[✓] Docker already installed: $(docker --version)"
fi

# 5. Determine application directory
REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$REPO_DIR"

# 6. Configure environment variables (.env)
if [ ! -f .env ]; then
    echo "[+] Generating production .env with secure random secrets..."
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
    echo "[✓] Created .env with randomized secrets."
else
    echo "[✓] Existing .env file found."
fi

# 7. Build and run production containers
echo "[+] Starting production containers..."
docker compose -f docker-compose.prod.yml down --remove-orphans 2>/dev/null || true
docker compose -f docker-compose.prod.yml up -d --build

# 8. Automated daily database backup at 03:00 AM
BACKUP_SCRIPT="$REPO_DIR/backup-db.sh"
chmod +x "$BACKUP_SCRIPT"
CRON_JOB="0 3 * * * $BACKUP_SCRIPT >> $REPO_DIR/backups/backup.log 2>&1"
(crontab -l 2>/dev/null | grep -v "backup-db.sh" ; echo "$CRON_JOB") | crontab -
echo "[✓] Configured automated daily database backup at 03:00 AM."

# 9. Health Check
echo "[+] Polling application status..."
MAX_RETRIES=35
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

PUBLIC_IP=$(curl -s https://ifconfig.me || curl -s https://checkip.amazonaws.com || echo "YOUR_OCI_PUBLIC_IP")

if [ "$HEALTHY" = true ]; then
    echo "=========================================================="
    echo "  Virtual Classroom successfully deployed on Oracle Cloud!"
    echo "=========================================================="
    echo " Public Access URL:    http://${PUBLIC_IP}"
    echo " Admin Login:          http://${PUBLIC_IP}/admin_login.jsp"
    echo " Faculty Login:        http://${PUBLIC_IP}/faculty_login.jsp"
    echo " Student Login:        http://${PUBLIC_IP}/student_login.jsp"
    echo " Status:               docker compose -f docker-compose.prod.yml ps"
    echo " Automated Backups:    ./backup-db.sh"
    echo "=========================================================="
    echo ""
    echo "[!] IMPORTANT: Ensure you have added an Ingress Rule for Port 80"
    echo "    in your OCI Console: Networking -> Virtual Cloud Networks ->"
    echo "    Default Security List -> Add Ingress Rule (CIDR: 0.0.0.0/0, Port: 80, 443)."
else
    echo "[!] Containers started, but healthcheck took longer than expected."
    echo "[!] Check container status: docker compose -f docker-compose.prod.yml logs"
fi
