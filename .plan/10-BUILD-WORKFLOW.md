# BUILD & DEVELOPMENT WORKFLOW

## Overview

Complete guide for building Lithium Browser from source.

---

## Prerequisites

### macOS Requirements

```bash
# Xcode Command Line Tools
xcode-select --install

# Homebrew packages
brew install coreutils gnu-sed quilt python3 ninja

# Disk space: ~100GB free
# RAM: 16GB minimum, 32GB recommended
# Time: 2-4 hours for full build
```

### Apple Silicon (arm64) vs Intel (x86_64)

The build automatically detects architecture. For cross-compilation, specify target.

---

## Quick Start

```bash
# 1. Clone repository
git clone --recurse-submodules git@github.com:deiviuds/lithium-macos.git
cd lithium-macos

# 2. Initialize environment
source dev.sh

# 3. Download Chromium source (first time only, ~20GB)
he fetch

# 4. Merge and apply patches
he merge
he push

# 5. Build
./build.sh arm64

# 6. Sign and package
./sign_and_package_app.sh
```

---

## Development Commands

### Environment Setup

```bash
source dev.sh
```

This loads:
- Environment variables from `env.sh`
- The `he` command helper
- Quilt configuration

### Helium Helper Commands

| Command | Description |
|---------|-------------|
| `he fetch` | Download Chromium source |
| `he merge` | Combine series files |
| `he push` | Apply all patches |
| `he pop` | Remove all patches |
| `he build` | Quick build (dev mode) |
| `he run` | Launch built browser |

### Full Build

```bash
# For Apple Silicon
./build.sh arm64

# For Intel
./build.sh x86-64

# Build output location
ls build/src/out/Default/Lithium.app
```

### Packaging

```bash
# Create signed DMG
./sign_and_package_app.sh

# Output
ls build/Lithium-*.dmg
```

---

## Incremental Development

### After Changing Patches

```bash
# 1. Remove current patches
he pop

# 2. Edit your patch files
vim patches/lithium/core/my-patch.patch

# 3. Re-merge (if series changed)
he merge

# 4. Re-apply
he push

# 5. Rebuild (incremental)
ninja -C build/src/out/Default chrome
```

### After Changing Source Directly

```bash
# 1. Make sure you're on the right patch
quilt top

# 2. Mark files for inclusion in patch
quilt add build/src/path/to/file.cc

# 3. Edit the file
vim build/src/path/to/file.cc

# 4. Update patch
quilt refresh

# 5. Rebuild
ninja -C build/src/out/Default chrome
```

---

## Build Configuration

### GN Flags

Combined from `flags.gn` (helium-chromium) and `flags.macos.gn`:

```gn
# Core settings
is_official_build = true
is_debug = false
is_clang = true
symbol_level = 1

# Codecs
proprietary_codecs = true
ffmpeg_branding = "Chrome"
enable_mse_mpeg2ts_stream_parser = true

# Features
enable_widevine = true
enable_rust = true
enable_swiftshader = true

# Disabled (privacy)
safe_browsing_mode = 0
enable_reporting = false
enable_remoting = false

# AI (Lithium addition)
use_on_device_model_service = true
```

### Customizing Flags

Edit `flags.macos.gn` to add or override flags:

```gn
# Example: Enable debug symbols
symbol_level = 2

# Example: Faster builds (less optimization)
is_official_build = false
```

---

## Troubleshooting

### Patch Apply Failures

```bash
# See which patch failed
quilt push 2>&1 | tail -20

# Force apply to see rejections
quilt push -f

# View rejection
cat build/src/path/to/file.cc.rej

# See AI_PATCH_FIXING.md for resolution
```

### Build Errors

```bash
# View full error
ninja -C build/src/out/Default chrome 2>&1 | tail -100

# Common: Missing dependency
gn gen build/src/out/Default --fail-on-unused-args

# Common: Stale build
rm -rf build/src/out/Default
./build.sh arm64
```

### Out of Memory

```bash
# Limit parallel jobs
ninja -C build/src/out/Default -j4 chrome

# Or set in build.sh
export NINJA_JOBS=4
```

### Disk Space

```bash
# Check usage
du -sh build/*

# Clean build artifacts (keeps source)
rm -rf build/src/out

# Full clean (re-download required)
rm -rf build/
```

---

## Testing

### Launch Built Browser

```bash
# Run directly
build/src/out/Default/Lithium.app/Contents/MacOS/Lithium

# Or use helper
he run
```

### Verify AI Features

1. Open `chrome://flags`
2. Search for "gemini"
3. Should see:
   - prompt-api-for-gemini-nano
   - summarization-api-for-gemini-nano
   - writer-api-for-gemini-nano
   - rewriter-api-for-gemini-nano
   - proofreader-api-for-gemini-nano

### Verify Branding

1. Open `chrome://settings/help`
2. Should show "Lithium" with version
3. Check `chrome://version` for detailed info

### Verify Keyboard Shortcuts

1. Open any webpage
2. Press Cmd+D → Address bar should focus
3. Press Cmd+Shift+D → Bookmark dialog should open

---

## Continuous Integration

### GitHub Actions Example

`.github/workflows/build.yml`:

```yaml
name: Build Lithium

on:
  push:
    tags: ['v*']

jobs:
  build:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4
        with:
          submodules: recursive
      
      - name: Install deps
        run: brew install coreutils gnu-sed quilt
      
      - name: Setup
        run: |
          source dev.sh
          he fetch
          he merge
          he push
      
      - name: Build
        run: ./build.sh arm64
      
      - name: Package
        run: ./sign_and_package_app.sh
      
      - name: Upload DMG
        uses: actions/upload-artifact@v4
        with:
          name: Lithium-DMG
          path: build/*.dmg
```

---

## Build Times (Approximate)

| Stage | First Build | Incremental |
|-------|-------------|-------------|
| Fetch source | 30-60 min | N/A |
| Apply patches | 1-2 min | 1-2 min |
| Full compile | 2-4 hours | 5-30 min |
| Package DMG | 5-10 min | 5-10 min |

*Times vary based on hardware. M1/M2/M3 Macs are significantly faster.*
