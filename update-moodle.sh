#!/bin/sh
set -e

CONTAINER_NAME="moodle-app"

echo "🚧 Enabling Maintenance Mode..."
docker exec -u www-data $CONTAINER_NAME php admin/cli/maintenance.php --enable

echo "📥 Pulling latest Moodle code..."
# We run git inside the container so it has access to the volume
docker exec -u www-data $CONTAINER_NAME git pull

echo "💾 Running Database Upgrade..."
# --non-interactive ensures it doesn't wait for you to type 'yes'
docker exec -u www-data $CONTAINER_NAME php admin/cli/upgrade.php --non-interactive

echo "🧹 Clearing Caches..."
docker exec -u www-data $CONTAINER_NAME php admin/cli/purge_caches.php

echo "🚀 Disabling Maintenance Mode..."
docker exec -u www-data $CONTAINER_NAME php admin/cli/maintenance.php --disable

echo "✅ Moodle updated successfully!"
