#!/bin/sh
set -e # Exit immediately if a command fails

TARGET="/target"

# FIX: Add the target directory to the safe list for Git
echo "🛡️ Configuring Git safe directory..."
git config --global --add safe.directory "$TARGET"

if [ ! -d "$TARGET/.git" ]; then
    echo "🚀 Cloning Moodle version ${MOODLE_VERSION}..."
    git clone --depth 1 --branch "${MOODLE_VERSION}" https://github.com/moodle/moodle.git "$TARGET"

    echo "📦 Installing Composer dependencies..."
    # We run this inside the TARGET directory where composer.json lives
    cd "$TARGET"
    composer install --no-dev --classmap-authoritative
    
    echo "📝 Creating config.php..."
    cat <<EOF > "$TARGET/config.php"
<?php
unset(\$CFG);
global \$CFG;
\$CFG = new stdClass();

\$CFG->dbtype    = 'pgsql';
\$CFG->dblibrary = 'native';
\$CFG->dbhost    = 'moodle-db';
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
