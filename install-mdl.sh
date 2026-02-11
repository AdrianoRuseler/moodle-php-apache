#!/bin/bash

# Exit on any error, treat unset variables as errors, and inherit traps
set -Eeuo pipefail

# Temporary working directories
WORK_DIR="/tmp/moodle_build"
MDLCORE="$WORK_DIR/core"
MDLPLGS="$WORK_DIR/plugins"
BACKUP_DIR="${MDLHOME}_bkp_$(date +%s)"

rm -rf $WORK_DIR && mkdir -p $WORK_DIR

# --- Rollback Function ---
rollback() {
    local exit_code=$?
    if [ $exit_code -ne 0 ]; then
        echo -e "\n\e[31m❌ ERROR: Deployment failed at line $1. Rolling back...\e[0m"
        
        # 1. If we already moved the old site, move it back
        if [ -d "$BACKUP_DIR" ]; then
            echo "🔄 Restoring old code from $BACKUP_DIR..."
            rm -rf "$MDLHOME"
            mv "$BACKUP_DIR" "$MDLHOME"
        fi
        
        # 2. Cleanup temp files
        rm -rf "$MDLCORE"
        
        echo -e "\e[32m✅ Rollback complete. Site is back to previous version.\e[0m"
    fi
}

# Link the rollback function to any Error (ERR)
trap 'rollback $LINENO' ERR

# 1. 🛡️ Handle Git Security (Dubious Ownership)
git config --global --add safe.directory "*"

# 2. 🚀 Clone Core and Plugins
echo "📥 Fetching Moodle Core ($MDLBRANCH)..."
git clone --depth=1 --branch=$MDLBRANCH $MDLREPO $MDLCORE

echo "📥 Fetching Custom Plugins ($PLGBRANCH)..."
git clone --depth=1 --recursive --branch=$PLGBRANCH $PLGREPO $MDLPLGS

# 3. 🧩 Merge Plugins into Core
echo "📂 Merging plugins into core..."
# We use -a (archive) to keep permissions and -v for visibility
rsync -av $MDLPLGS/moodle/ $MDLCORE/

# 4. 📦 Install Composer Dependencies
# CRITICAL: This must happen after merging in case plugins have their own requirements
echo "📦 Installing Composer dependencies..."
cd $MDLCORE
composer install --no-dev --classmap-authoritative

# 4. 🔄 The Swap
echo "🚚 Moving files to destination..."
if [ -d "$MDLHOME" ]; then
    # Backup config.php before moving old files
    cp "$MDLHOME/config.php" "/tmp/config.php.tmp"
    mv "$MDLHOME" "${MDLHOME}_old_$(date +%s)"
fi

mkdir -p "$MDLHOME"
# Move everything including hidden files
mv $MDLCORE/* $MDLHOME/
mv $MDLCORE/.[!.]* $MDLHOME/ 2>/dev/null || true 

echo "📝 Restoring config.php..."
mv "/tmp/config.php.tmp" "$MDLHOME/config.php"

# 5. 🔐 Permissions & Upgrade
echo "🔐 Setting ownership..."
chown -R 33:33 $MDLHOME

echo "🆙 Running Database Upgrade..."
#docker exec -u www-data moodle-cron php $MDLHOME/admin/cli/upgrade.php --non-interactive --allow-unstable

echo "🧹 Purging Caches..."
#docker exec -u www-data moodle-cron php $MDLHOME/admin/cli/purge_caches.php

echo "✅ Deployment Complete!"
