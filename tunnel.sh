#!/usr/bin/env bash
# ==============================================================================
# Virtual Classroom — Instant Free Public Terminal Tunnel (Zero Hosting Cost)
# Exposes your locally running Docker stack to a secure public HTTPS URL.
# ==============================================================================
set -euo pipefail

cd "$(dirname "$0")"

echo "=========================================================="
echo " Virtual Classroom — Instant Free Terminal Deployment"
echo "=========================================================="

# 1. Verify Docker stack is running locally
if ! curl -s -f http://localhost:80/ > /dev/null 2>&1; then
    echo "[!] Local stack is not responding on port 80."
    echo "[+] Starting local containers..."
    docker compose up -d
    echo "[+] Waiting for containers to be ready..."
    until curl -s -f http://localhost:80/ > /dev/null 2>&1; do
        sleep 2
        printf "."
    done
    echo ""
    echo "[✓] Local stack is healthy on http://localhost:80"
fi

echo ""
echo "[✓] Local stack confirmed running on http://localhost:80"
echo "[+] Initializing Cloudflare Tunnel (100% Free, HTTPS, No Session Limits)..."
echo "=========================================================="
echo " Your public HTTPS URL will appear below in 2-3 seconds:"
echo " (Press Ctrl+C at any time to stop public access)"
echo "=========================================================="
echo ""

if command -v cloudflared &> /dev/null; then
    exec cloudflared tunnel --url http://localhost:80
elif command -v ngrok &> /dev/null; then
    echo "[!] cloudflared not found. Falling back to ngrok..."
    exec ngrok http 80
else
    echo "[!] Neither cloudflared nor ngrok found."
    echo "[+] Install cloudflared for free: brew install cloudflared"
    echo "[+] Or install ngrok: brew install ngrok"
    exit 1
fi
