#!/usr/bin/env bash
set -e

cd "$(dirname "$0")"

BACKUP_DIR="backups"
mkdir -p "$BACKUP_DIR"

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
FILENAME="$BACKUP_DIR/project_backup_$TIMESTAMP.sql"

echo "Creating database backup to $FILENAME..."

# Load credentials from .env if present
if [ -f .env ]; then
    export $(cat .env | grep -v '#' | awk '/=/ {print $1}')
fi

ROOT_PASS="${MYSQL_ROOT_PASSWORD:-Mypasswordis2425}"

docker exec virtual_classroom_db mysqldump -u root -p"$ROOT_PASS" project > "$FILENAME"

echo "Backup completed successfully ($FILENAME)."
echo "Total backups:"
ls -lh "$BACKUP_DIR"
