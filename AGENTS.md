# AGENTS.md - Lithium Browser Development Guide

## Project Overview

Lithium Browser is a privacy-focused Chromium fork based on Helium that re-enables Chrome's native client-side AI features (Gemini Nano, Prompt API, Summarizer, Writer, Rewriter, Proofreader) while maintaining privacy protections. Target: macOS arm64.

## Repository Structure

```
lithium-macos/                    # Platform repository (this repo)
├── helium-chromium/              # Submodule: deiviuds/lithium-chromium (core patches)
├── patches/
│   ├── series                    # macOS patches list
│   └── lithium/macos/            # Lithium macOS-specific patches
├── dev.sh                        # Development environment (defines `he` command)
├── build.sh                      # Full build script
├── flags.macos.gn                # macOS GN build flags
└── .plan/                        # Complete project documentation
```

## Build Commands

```bash
# Setup environment (REQUIRED first step)
source dev.sh

# Download Chromium source (~20GB, first time only)
he fetch

# Merge series files (helium-chromium + macos patches)
he merge

# Apply all patches to build/src/
he push

# Full build for Apple Silicon
./build.sh arm64

# Incremental rebuild after source changes
ninja -C build/src/out/Default chrome

# Run the built browser
he run
# or: build/src/out/Default/Lithium.app/Contents/MacOS/Lithium

# Create DMG package
./sign_and_package_app.sh
```

## Patch Management (Quilt)

```bash
# Remove all patches
he pop
# or: quilt pop -a

# Apply patches one by one
quilt push

# Apply all patches
quilt push -a

# See applied patches
quilt applied

# See current top patch
quilt top

# Create new patch
quilt new lithium/macos/my-feature.patch
quilt add build/src/path/to/file.cc
# Edit file...
quilt refresh

# Update existing patch after edits
quilt refresh
```

### Fixing Failed Patches

When `quilt push` fails:
1. Run `quilt push -f` to force apply and generate .rej files
2. View rejection: `cat build/src/path/to/file.cc.rej`
3. Manually edit the source file to apply intended changes
4. Run `quilt refresh` to update the patch
5. Delete .rej files and continue with `quilt push -a`

See `.plan/09-AI-PATCH-FIXING.md` for detailed AI-assisted fixing workflow.

## Code Style Guidelines

### Patch Format (Unified Diff)

```patch
Description of what this patch does

--- a/path/to/file.cc
+++ b/path/to/file.cc
@@ -123,6 +123,7 @@ void SomeFunction() {
   // context line (3+ lines recommended)
-  // line being removed
+  // line being added
   // more context
 }
```

- Use `-p1` format with `a/` and `b/` prefixes
- Include 3+ context lines for resilience to upstream changes
- End files with newline
- Add header comment describing patch purpose

### C++ (Chromium Style)

- 2-space indentation
- Opening braces on same line
- `nullptr` not `NULL`
- Use `base::` containers over STL when available
- Follow [Chromium C++ Style Guide](https://chromium.googlesource.com/chromium/src/+/main/styleguide/c++/c++.md)

### GN Build Files

```gn
# Boolean flags
is_official_build = true
enable_widevine = true
safe_browsing_mode = 0

# String values
ffmpeg_branding = "Chrome"
```

### Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Patches | kebab-case | `enable-on-device-model.patch` |
| Variables | snake_case | `use_on_device_model_service` |
| C++ functions | PascalCase | `GetLithiumVersionNumber()` |
| Constants | kPascalCase | `kExcludedFlags` |

## Key Files to Understand

| File | Purpose |
|------|---------|
| `dev.sh` | Environment setup, defines `he` command |
| `env.sh` | Environment variables (_src_dir, _arch, etc.) |
| `flags.macos.gn` | macOS-specific build flags |
| `patches/series` | Ordered list of macOS patches |
| `helium-chromium/patches/series` | Core cross-platform patches |

## Critical Patches (Lithium Overrides)

### Core Patches (in helium-chromium/patches/lithium/core/)

| Patch | Target | Purpose |
|-------|--------|---------|
| `enable-on-device-model.patch` | features.gni | Set `use_on_device_model_service=true` |
| `restore-ai-flags.patch` | about_flags.cc | Remove AI flags from kExcludedFlags |
| `allow-ai-components.patch` | component_installer.cc | Add OptimizationGuidePredictionModels to allowlist |
| `lithium-branding.patch` | BRANDING | Product name, bundle ID, company |
| `lithium-versioning.patch` | Multiple version files | HELIUM_ -> LITHIUM_ |

### macOS Patches (in patches/lithium/macos/)

| Patch | Target | Purpose |
|-------|--------|---------|
| `keyboard-shortcuts.patch` | global_keyboard_shortcuts_mac.mm | Cmd+D -> focus address bar |
| `lithium-keychain.patch` | keychain_password_mac.mm | Keychain entry name |
| `lithium-product-dir.patch` | chrome_paths_mac.mm | App Support directory |

## Error Handling

### Patch Failures

```bash
# See detailed error
quilt push 2>&1 | tail -20

# Force and inspect rejections
quilt push -f
find build/src -name "*.rej" -exec cat {} \;
```

### Build Failures

```bash
# View full error
ninja -C build/src/out/Default chrome 2>&1 | tail -100

# Regenerate build files
gn gen build/src/out/Default --fail-on-unused-args

# Clean rebuild (preserves source)
rm -rf build/src/out/Default
./build.sh arm64
```

### Out of Memory

```bash
# Limit parallel jobs
ninja -C build/src/out/Default -j4 chrome
```

## Git Workflow

```bash
# Add upstream remotes
git remote add upstream https://github.com/imputnet/helium-macos.git
cd helium-chromium
git remote add upstream https://github.com/imputnet/helium.git

# Sync with upstream (run sync-upstream.sh or manually)
git fetch upstream
git merge upstream/main
```

## Verification Checklist

After building, verify:
1. `chrome://flags` - AI flags visible (gemini-nano, summarizer, writer, etc.)
2. `chrome://settings/help` - Shows "Lithium"
3. `chrome://version` - Shows Lithium branding
4. Cmd+D - Focuses address bar
5. Cmd+Shift+D - Opens bookmark dialog
6. Keychain Access - Entry shows "Lithium Storage Key"

## Important Notes

- All AI features are on-device, require NO API keys
- Translation features remain DISABLED (user preference)
- @gemini shortcuts remain DISABLED (Helium default)
- Unsigned builds: Right-click -> Open -> Open to bypass Gatekeeper
- Build time: 2-4 hours first build, 5-30 min incremental
- Disk space: ~100GB required
- RAM: 16GB minimum, 32GB recommended

## Documentation Reference

Complete project documentation in `.plan/`:
- `README.md` - Documentation index and navigation
- `00-OVERVIEW.md` - Project goals, configuration, and feature matrix
- `01-ARCHITECTURE.md` - Patch system, directory structure, and build flags
- `02-AI-FEATURES.md` - AI feature technical specs and dependencies
- `03-TRANSLATION.md` - Translation feature analysis (disabled by choice)
- `04-BRANDING.md` - Branding changes from Helium to Lithium
- `05-KEYBOARD-SHORTCUTS.md` - Cmd+D/Cmd+Shift+D shortcut changes
- `06-PATCHES.md` - Exact patch contents to create (8 patches)
- `07-GIT-WORKFLOW.md` - Forking strategy and upstream sync workflow
- `08-QUILT-WORKFLOW.md` - Quilt commands and patch management
- `09-AI-PATCH-FIXING.md` - AI-assisted patch conflict resolution
- `10-BUILD-WORKFLOW.md` - Build commands and troubleshooting
- `11-CHECKLIST.md` - Implementation checklist with phases
- `12-REFERENCE-PATCHES.md` - Analysis of all Helium patches
