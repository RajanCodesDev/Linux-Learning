#!/bin/bash

set -e

TARGET_PATH="$1"

if [ -z "$TARGET_PATH" ]; then
    echo "Usage: ./wp-gitops-init.sh /path/to/wp-content"
    exit 1
fi

cd "$TARGET_PATH"

echo "========================================="
echo "WORDPRESS GITOPS INITIALIZER"
echo "========================================="
echo

echo "[1/8] Verifying WordPress environment..."

if [ ! -d plugins ] || [ ! -d themes ]; then
    echo "[FAIL] Not a valid wp-content directory"
    exit 1
fi

echo "[OK] wp-content detected"

echo

echo "[2/8] Running plugin checksum verification..."


CHECKSUM_OUTPUT=$(wp plugin verify-checksums --all --allow-root 2>&1 || true)

echo "$CHECKSUM_OUTPUT"

echo


echo "[3/8] Detecting custom/vendor plugins..."

TMP_CUSTOM=$(mktemp)

(
echo "$CHECKSUM_OUTPUT" \
| grep "Could not retrieve the checksums for version" \
| sed -E 's/.*plugin ([^,]+),.*/\1/'

echo "$CHECKSUM_OUTPUT" \
| grep "File was added\|File doesn't verify against checksum\|File should not exist" \
| awk '{print $1}'

) | sort -u > "$TMP_CUSTOM"

if [ -f ignore-modified-plugins.txt ]; then
    grep -vxFf ignore-modified-plugins.txt "$TMP_CUSTOM" > custom-plugins.txt || true
else
    cp "$TMP_CUSTOM" custom-plugins.txt
fi

rm -f "$TMP_CUSTOM"

echo "[OK] custom-plugins.txt generated"

echo
echo "Detected custom/vendor plugins:"
cat custom-plugins.txt


echo


echo "[4/8] Generating plugins.json..."



CUSTOM_REGEX=$(paste -sd'|' custom-plugins.txt 2>/dev/null || true)

wp plugin list --field=name --allow-root \
| if [ -n "$CUSTOM_REGEX" ]; then
    grep -vE "^($CUSTOM_REGEX)$"
else
    cat
fi \
| jq -R . \
| jq -s . \
> plugins.json

echo "[OK] plugins.json generated"

echo
echo "Commodity plugins:"
cat plugins.json | jq


echo


echo "[5/8] Detecting tracked themes..."

ACTIVE_THEME=$(wp theme list --status=active --field=name --allow-root)

echo "$ACTIVE_THEME" > custom-themes.txt

PARENT_THEME=$(wp theme get "$ACTIVE_THEME" --field=template --allow-root 2>/dev/null || true)

if [ -n "$PARENT_THEME" ] && [ "$PARENT_THEME" != "$ACTIVE_THEME" ]; then
    echo "$PARENT_THEME" >> custom-themes.txt
fi

sort -u custom-themes.txt -o custom-themes.txt

echo "[OK] custom-themes.txt generated"

echo
echo "Tracked themes:"
cat custom-themes.txt



echo "[6/8] Generating .gitignore..."



cat > .gitignore <<'EOF'
# =========================================================
# RUNTIME
# =========================================================
uploads/
upgrade/
upgrade-temp-backup/
wflogs/
cache/

# =========================================================
# IGNORE ALL PLUGINS
# =========================================================
plugins/*
!plugins/index.php

EOF

while read plugin; do
    echo "!plugins/$plugin/" >> .gitignore
    echo "!plugins/$plugin/**" >> .gitignore
    echo >> .gitignore
done < custom-plugins.txt

cat >> .gitignore <<'EOF'

# =========================================================
# IGNORE ALL THEMES
# =========================================================
themes/*
!themes/index.php

EOF

# for theme in $(wp theme list --field=name --allow-root); do
#     echo "!themes/$theme/" >> .gitignore
#     echo "!themes/$theme/**" >> .gitignore
#     echo >> .gitignore
# done

while read theme; do
     echo "!themes/$theme/" >> .gitignore
     echo "!themes/$theme/**" >> .gitignore
     echo >> .gitignore
done < custom-themes.txt


cat >> .gitignore <<'EOF'

# =========================================================
# TEMP / GENERATED
# =========================================================
*.zip
*.tar
*.sql
*.log
*.wpress

# =========================================================
# NODE / BUILD
# =========================================================
node_modules/

# =========================================================
# EDITOR
# =========================================================
.vscode/
.idea/
.DS_Store
EOF

echo "[OK] .gitignore generated"

echo

echo
echo "[7/8] Generating scripts..."

mkdir -p scripts

# 1
cat > scripts/generate_plugins_manifest.sh <<'EOF'
#!/bin/bash

set -e

echo "Generating plugins.json..."

CUSTOM_REGEX=$(paste -sd'|' custom-plugins.txt 2>/dev/null || true)

wp plugin list --field=name --allow-root \
| if [ -n "$CUSTOM_REGEX" ]; then
    grep -vE "^($CUSTOM_REGEX)$"
else
    cat
fi \
| jq -R . \
| jq -s . \
> plugins.json

echo "[OK] plugins.json updated"
EOF


#2
cat > scripts/install_plugins.sh <<'EOF'
#!/bin/bash

set -e

echo "========================================="
echo "INSTALLING COMMODITY PLUGINS"
echo "========================================="

DISABLED_DIR=".gitops-disabled-plugins"

mkdir -p "$DISABLED_DIR"

echo
echo "[1/5] Temporarily isolating tracked plugins..."

while read plugin; do

    if [ -d "plugins/$plugin" ]; then

        echo "[DISABLE] $plugin"

        mv "plugins/$plugin" "$DISABLED_DIR/$plugin"

    fi

done < custom-plugins.txt

echo
echo "[2/5] Installing commodity plugins..."

jq -r '.[]' plugins.json | while read plugin; do

    if wp plugin is-installed "$plugin" --allow-root 2>/dev/null; then
        echo "[SKIP] $plugin already installed"
    else
        echo "[INSTALL] $plugin"
        wp plugin install "$plugin" --activate --allow-root
    fi

done

echo
echo "[3/5] Restoring tracked plugins..."

while read plugin; do

    if [ -d "$DISABLED_DIR/$plugin" ]; then

        echo "[RESTORE] $plugin"

        mv "$DISABLED_DIR/$plugin" "plugins/$plugin"

    fi

done < custom-plugins.txt

echo
echo "[4/5] Activating tracked plugins..."

while read plugin; do

    if [ -d "plugins/$plugin" ]; then

        echo "[ACTIVATE] $plugin"

        wp plugin activate "$plugin" --allow-root || true

    fi

done < custom-plugins.txt

echo
echo "[5/5] Flushing cache..."

wp cache flush --allow-root || true

rm -rf "$DISABLED_DIR"

echo
echo "[OK] Commodity plugin installation complete"
EOF


#3
cat > scripts/verify_wordpress_state.sh <<'EOF'
#!/bin/bash

set -e

echo "========================================="
echo "VERIFYING WORDPRESS STATE"
echo "========================================="

echo
echo "[1/4] Verifying WordPress core..."

wp core verify-checksums --allow-root

echo
echo "[2/4] Verifying plugin checksums..."

wp plugin verify-checksums --all --allow-root || true

echo
echo "[3/4] Checking repository pollution..."

BAD_FILES=$(git status --porcelain | awk '{print $2}' | grep -E '(uploads/|ai1wm-backups/|\.sql$|\.zip$|\.tar$|\.gz$|\.wpress$|node_modules/|cache/|wflogs/)') || true

if [ -n "$BAD_FILES" ]; then
    echo
    echo "[FAIL] Repository pollution detected:"
    echo "$BAD_FILES"
    exit 1
fi

echo
echo "[4/4] Git status..."

git status --short

echo
echo "[OK] Repository state clean"
EOF



cat > scripts/pre-push <<'EOF'
#!/bin/bash

set -e

echo "========================================="
echo "RUNNING PRE-PUSH TASKS"
echo "========================================="

echo
echo "[1/3] Regenerating plugin manifest..."

./scripts/generate_plugins_manifest.sh

echo
echo "[2/3] Staging manifest..."

git add plugins.json

echo
echo "[3/3] Verifying repository..."

./scripts/verify_wordpress_state.sh

echo
echo "[OK] Pre-push checks completed"
EOF



chmod +x scripts/*.sh
chmod +x scripts/pre-push

echo "[OK] scripts generated"


echo
echo "[8/8] Installing Git hook..."

if [ ! -d .git ]; then
    echo "[INFO] Initializing Git repository..."
    git init
fi

if [ -d .git ]; then

    mkdir -p .git/hooks

    if [ ! -f .git/hooks/pre-push ] || ! cmp -s scripts/pre-push .git/hooks/pre-push; then
        cp scripts/pre-push .git/hooks/pre-push
        chmod +x .git/hooks/pre-push
        echo "[OK] pre-push hook installed"
    else
        echo "[OK] pre-push hook already up to date"
    fi

else
    echo "[WARN] No Git repository detected, skipping hook install"
fi

echo
echo "[FINAL] Verifying repository state..."

./scripts/verify_wordpress_state.sh
