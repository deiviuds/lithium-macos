# GIT WORKFLOW & FORKING STRATEGY

## Overview

This document describes the Git workflow for maintaining Lithium Browser with easy upstream syncing from Helium.

---

## Repository Structure

### GitHub Organization

```
deiviuds/
├── lithium-chromium          # Fork of imputnet/helium
│   └── (core cross-platform patches)
│
└── lithium-macos             # Fork of imputnet/helium-macos
    └── helium-chromium/      # Submodule → deiviuds/lithium-chromium
```

### Remote Configuration

**In lithium-macos:**
```bash
origin    git@github.com:deiviuds/lithium-macos.git (fetch/push)
upstream  https://github.com/imputnet/helium-macos.git (fetch)
```

**In lithium-chromium:**
```bash
origin    git@github.com:deiviuds/lithium-chromium.git (fetch/push)
upstream  https://github.com/imputnet/helium.git (fetch)
```

---

## Initial Setup

### Step 1: Fork Repositories on GitHub

1. Go to https://github.com/imputnet/helium
2. Click "Fork" → Create `deiviuds/lithium-chromium`

3. Go to https://github.com/imputnet/helium-macos
4. Click "Fork" → Create `deiviuds/lithium-macos`

### Step 2: Clone and Configure Locally

```bash
# Clone your lithium-macos fork
git clone git@github.com:deiviuds/lithium-macos.git
cd lithium-macos

# Add upstream remote
git remote add upstream https://github.com/imputnet/helium-macos.git

# Update submodule to point to YOUR fork
git submodule deinit helium-chromium
rm -rf .git/modules/helium-chromium
rm -rf helium-chromium

# Re-add as your fork
git submodule add git@github.com:deiviuds/lithium-chromium.git helium-chromium

# Update .gitmodules
cat > .gitmodules << 'EOF'
[submodule "helium-chromium"]
	path = helium-chromium
	url = https://github.com/deiviuds/lithium-chromium.git
EOF

# Configure helium-chromium with upstream
cd helium-chromium
git remote add upstream https://github.com/imputnet/helium.git
cd ..

# Commit the submodule change
git add .gitmodules helium-chromium
git commit -m "Point submodule to lithium-chromium fork"
```

---

## Branch Strategy

```
main                          # Stable releases
├── develop                   # Integration branch
├── feature/ai-flags          # Feature branches
├── feature/branding
├── feature/keyboard
└── upstream-sync             # Temporary branch for syncing
```

### Branch Rules

| Branch | Purpose | Protection |
|--------|---------|------------|
| `main` | Stable releases | Require PR, no force push |
| `develop` | Integration | Require PR |
| `feature/*` | New features | None |
| `upstream-sync` | Sync work | None, delete after merge |

---

## Daily Development Workflow

### Starting Work

```bash
cd lithium-macos
git checkout develop
git pull origin develop
git submodule update --init --recursive

# Create feature branch
git checkout -b feature/my-feature
```

### Making Changes

```bash
# Edit patches in patches/lithium/ or helium-chromium/patches/lithium/

# Test patches apply
source dev.sh
he merge
he push

# Commit
git add .
git commit -m "Add feature X"
git push origin feature/my-feature

# Create Pull Request on GitHub
```

### If Editing Core Patches (in helium-chromium)

```bash
cd helium-chromium
git checkout -b feature/my-core-feature
# ... edit patches ...
git add .
git commit -m "Core: add feature X"
git push origin feature/my-core-feature

# Go back to parent and update submodule reference
cd ..
git add helium-chromium
git commit -m "Update helium-chromium submodule"
git push origin feature/my-feature
```

---

## Syncing with Upstream Helium

### When to Sync

- Weekly recommended
- When Helium releases new version
- When Chromium has security updates

### Sync Script

Create `sync-upstream.sh`:

```bash
#!/bin/bash
set -e

echo "=== Syncing lithium-chromium with upstream helium ==="
cd helium-chromium

# Fetch upstream
git fetch upstream

# Create sync branch
git checkout -b upstream-sync-$(date +%Y%m%d) main

# Merge upstream
git merge upstream/main --no-edit || {
    echo ""
    echo "CONFLICT in helium-chromium!"
    echo "Resolve conflicts, then run:"
    echo "  git add . && git commit"
    echo "  git checkout main && git merge upstream-sync-*"
    echo ""
    exit 1
}

# Fast-forward main
git checkout main
git merge upstream-sync-$(date +%Y%m%d)
git push origin main

# Cleanup
git branch -d upstream-sync-$(date +%Y%m%d)

cd ..

echo "=== Syncing lithium-macos with upstream helium-macos ==="

# Fetch upstream
git fetch upstream

# Create sync branch
git checkout -b upstream-sync-$(date +%Y%m%d) main

# Merge upstream
git merge upstream/main --no-edit || {
    echo ""
    echo "CONFLICT in helium-macos!"
    echo "Resolve conflicts, then run:"
    echo "  git add . && git commit"
    echo "  git checkout main && git merge upstream-sync-*"
    echo ""
    exit 1
}

# Update submodule reference
git add helium-chromium
git commit -m "Update submodule after upstream sync" || true

# Fast-forward main
git checkout main
git merge upstream-sync-$(date +%Y%m%d)
git push origin main

# Cleanup
git branch -d upstream-sync-$(date +%Y%m%d)

echo "=== Sync complete ==="
echo "Now test with: source dev.sh && he merge && he push"
```

### Handling Merge Conflicts

When conflicts occur during sync:

1. **Identify conflicting files:**
   ```bash
   git status
   ```

2. **For patch conflicts, use AI assistance:**
   See `AI_PATCH_FIXING.md`

3. **After resolving:**
   ```bash
   git add .
   git commit -m "Resolve upstream merge conflicts"
   git checkout main
   git merge upstream-sync-*
   ```

---

## Version Tagging

### Creating a Release

```bash
# Ensure main is up to date
git checkout main
git pull origin main
git submodule update --init --recursive

# Update revision.txt
echo "1.0.0.1" > revision.txt

# Tag the release
git add revision.txt
git commit -m "Release v1.0.0"
git tag -a v1.0.0 -m "Lithium Browser v1.0.0"

# Push
git push origin main --tags
```

### Tag Format

```
v{MAJOR}.{MINOR}.{PATCH}

Examples:
v1.0.0   - First stable release
v1.0.1   - Bug fix
v1.1.0   - New features
v2.0.0   - Major changes
```

---

## CI/CD (Optional)

### GitHub Actions Workflow

`.github/workflows/validate.yml`:

```yaml
name: Validate Patches

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      
      - name: Install dependencies
        run: brew install coreutils gnu-sed quilt
      
      - name: Validate patch stack
        run: |
          source dev.sh
          he merge
          # Dry-run push to validate
          quilt push -a --dry-run
```

---

## Quick Reference

| Task | Command |
|------|---------|
| Start feature | `git checkout -b feature/name develop` |
| Test patches | `source dev.sh && he merge && he push` |
| Commit | `git add . && git commit -m "message"` |
| Push | `git push origin feature/name` |
| Sync upstream | `./sync-upstream.sh` |
| Create release | `git tag -a vX.Y.Z -m "message" && git push --tags` |
