#!/usr/bin/env bash
# Generate Assets.car from Lithium icon
# This script must be run on a Mac with full Xcode installed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR/app_icon"

echo "Generating Assets.car from Lithium icon..."

# Compile Assets.xcassets to Assets.car
xcrun actool Assets.xcassets \
    --compile . \
    --platform macosx \
    --minimum-deployment-target 10.13 \
    --app-icon AppIcon \
    --output-partial-info-plist /dev/null

echo "✓ Assets.car generated successfully"
ls -lh Assets.car
