#!/bin/sh
set -e # Exit immediately if a command fails

TARGET="${MDLHOME}"

# Temporary working directories
WORK_DIR="/tmp/moodle_build"
MDLCORE="$WORK_DIR/core"
MDLPLGS="$WORK_DIR/plugins"

PLGREPO="https://github.com/${PLGSREPO}.git"

rm -rf $WORK_DIR && mkdir -p $WORK_DIR

# FIX: Add the target directory to the safe list for Git
echo "🛡️ Configuring Git safe directory..."
git config --global --add safe.directory "$TARGET"

if [ ! -d "$TARGET/.git" ]; then
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

    mkdir -p "$MDLHOME"
    # Move everything including hidden files
    mv $MDLCORE/* $MDLHOME/
    mv $MDLCORE/.[!.]* $MDLHOME/ 2>/dev/null || true 

    echo "📝 Creating config.php..."
    cat <<EOF > "$TARGET/config.php"
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = '${DB_TYPE}';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = '${DB_HOST}';
\$CFG->dbname    = '${DB_NAME}';
\$CFG->dbuser    = '${DB_USER}';
\$CFG->dbpass    = '${DB_PASS}';
\$CFG->prefix    = 'mdl_';
\$CFG->dboptions = ['dbcollation' => 'utf8mb4_unicode_ci'];

\$CFG->wwwroot   = '${MOODLE_URL}';
\$CFG->dataroot  = '/var/www/moodledata';
\$CFG->admin     = 'admin';

// System Paths
\$CFG->pathtogs = '${PATH_TO_GS}';
\$CFG->pathtodot = '${PATH_TO_DOT}';
\$CFG->aspellpath = '${PATH_TO_ASPELL}';
\$CFG->pathtopython = '${PATH_TO_PYTHON}';

\$CFG->directorypermissions = 0777;

require_once(__DIR__ . '/lib/setup.php');
EOF

    echo "🔐 Setting permissions..."
    chown -R 33:33 "$TARGET"
    echo "✅ Init complete."
else
    echo "ℹ️ Moodle code already exists, skipping clone."
    # Optional: Run composer install again in case dependencies changed
    cd "$TARGET"
    composer install --no-dev --classmap-authoritative
fi
