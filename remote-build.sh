#!/usr/bin/env bash
set -e

echo "========================================="
echo "Lithium Browser Remote Build Script"
echo "========================================="

# Phase 2: Verify Prerequisites
echo ""
echo "Phase 2: Checking Prerequisites..."
echo "-----------------------------------"

# Check Xcode
if xcode-select -p &>/dev/null; then
    echo "✓ Xcode Command Line Tools: $(xcode-select -p)"
else
    echo "✗ Xcode Command Line Tools not found!"
    exit 1
fi

# Check Homebrew
if command -v brew &>/dev/null; then
    echo "✓ Homebrew: $(brew --version | head -1)"
else
    echo "✗ Homebrew not found! Installing..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Check/install required tools
echo ""
echo "Checking required tools..."
for tool in greadlink quilt ninja jq; do
    if command -v $tool &>/dev/null; then
        echo "✓ $tool installed"
    else
        echo "Installing $tool..."
        brew install $tool
    fi
done

# Check disk space
echo ""
echo "Disk Space:"
df -h / | tail -1

# Check RAM
echo ""
echo "Memory:"
system_profiler SPHardwareDataType | grep "Memory:"

# Phase 3: Clone Repository
echo ""
echo "Phase 3: Setting Up Repository..."
echo "-----------------------------------"

cd ~
if [ -d "lithium-macos" ]; then
    echo "lithium-macos directory exists. Removing old version..."
    rm -rf lithium-macos
fi

echo "Cloning lithium-macos repository..."
git clone --recursive https://github.com/deiviuds/lithium-macos.git
cd lithium-macos

echo "✓ Repository cloned successfully"
echo "Current directory: $(pwd)"
echo "Git status:"
git status --short
echo ""
echo "Submodule status:"
git submodule status

echo ""
echo "========================================="
echo "Prerequisites Complete!"
echo "========================================="
echo ""
echo "Next steps to run manually:"
echo "1. cd ~/lithium-macos"
echo "2. source dev.sh"
echo "3. he setup      # Downloads Chromium + applies patches"
echo "4. ./build.sh arm64    # Build browser (2-4 hours)"
echo "5. ./sign_and_package_app.sh    # Create DMG"
