#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

echo "========================================="
echo " Starting Virtual Classroom (Production) "
echo "========================================="

docker compose up -d --build

echo ""
echo "Waiting for web application and Nginx reverse proxy to be ready..."
until curl -s http://localhost:8080/ > /dev/null; do
    sleep 2
    printf "."
done

echo ""
echo "========================================================="
echo " Virtual Classroom is UP AND RUNNING!"
echo " Primary Gateway (Nginx): http://localhost"
echo " Direct Tomcat Access:    http://localhost:8080"
echo " Admin Default Password:  Mypasswordis2425"
echo " Database Backup Command: ./backup-db.sh"
echo "========================================================="
