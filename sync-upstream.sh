#!/bin/bash
# Lithium Browser: Sync with upstream Helium repositories
#
# This script fetches and merges changes from the upstream Helium repos.
# Run this periodically to stay up-to-date with Helium improvements.
#
# Usage: ./sync-upstream.sh

set -e

echo "=== Lithium Upstream Sync ==="
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo "Error: You have uncommitted changes. Please commit or stash them first."
    exit 1
fi

cd "$(dirname "$0")"

echo "[1/4] Syncing lithium-macos with upstream helium-macos..."
git fetch upstream
git merge upstream/main -m "chore: merge upstream helium-macos changes"

echo ""
echo "[2/4] Syncing helium-chromium submodule with upstream helium..."
cd helium-chromium
git fetch upstream
git merge upstream/main -m "chore: merge upstream helium changes"
cd ..

echo ""
echo "[3/4] Updating submodule reference..."
git add helium-chromium

# Only commit if there are changes
if ! git diff --cached --quiet; then
    git commit -m "chore: update helium-chromium submodule after upstream sync"
fi

echo ""
echo "[4/4] Done!"
echo ""
echo "Next steps:"
echo "  1. Review the changes: git log --oneline -10"
echo "  2. Test the build: source dev.sh && he setup"
echo "  3. If patches fail, see AI_PATCH_FIXING.md"
echo "  4. Push when ready: git push origin main"
echo ""
