#!/usr/bin/env bash
cd "$(dirname "$0")"

echo "Stopping Virtual Classroom..."
docker compose down
echo "Virtual Classroom stopped."
