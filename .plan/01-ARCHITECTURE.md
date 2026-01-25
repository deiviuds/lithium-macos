# ARCHITECTURE ANALYSIS

## Helium's Patch System Overview

Helium uses a two-tier patch organization with `quilt` for patch management. Patches are organized into a "series" that applies in order to the Chromium source.

---

## Directory Structure

### helium-macos (Platform Repository)

```
helium-macos/
├── helium-chromium/                 # Git submodule (cross-platform patches)
├── patches/
│   ├── series                       # 28 macOS-specific patches
│   ├── ungoogled-chromium/macos/    # macOS build fixes
│   │   ├── build-bindgen.patch
│   │   ├── disable-clang-version-check.patch
│   │   ├── disable-crashpad-handler.patch
│   │   ├── fix-disabling-safebrowsing.patch  # IMPORTANT: Removes TranslateKit
│   │   └── ...
│   ├── helium/macos/
│   │   ├── change-keychain-name.patch
│   │   ├── change-product-dir-name.patch
│   │   ├── clean-main-menu.patch
│   │   └── ...
│   └── rebel/macos/
│       └── sparkle-integration.patch
├── resources/
│   └── assets/                      # Icons, DMG config
├── devutils/                        # Development utilities
├── dev.sh                           # Development commands (he)
├── build.sh                         # Full build script
├── env.sh                           # Environment variables
├── flags.macos.gn                   # macOS GN build flags
├── revision.txt                     # Helium version
└── downloads*.ini                   # Chromium source downloads
```

### helium-chromium (Core Repository)

```
helium-chromium/
├── patches/
│   ├── series                       # 269 cross-platform patches
│   ├── upstream-fixes/              # Chromium bug fixes
│   ├── inox-patchset/               # Privacy defaults
│   │   ├── fix-building-without-safebrowsing.patch
│   │   ├── disable-autofill-download-manager.patch
│   │   ├── disable-update-pings.patch
│   │   ├── disable-rlz.patch
│   │   └── modify-default-prefs.patch  # Sets translate=false
│   ├── iridium-browser/
│   │   ├── safe-browsing-disable-reporting.patch
│   │   ├── all-add-trk-prefixes-to-possibly-evil-connections.patch  # Blocks translate API
│   │   └── updater-disable-auto-update.patch
│   ├── ungoogled-chromium/          # 71+ privacy patches
│   │   ├── disable-crash-reporter.patch
│   │   ├── disable-google-host-detection.patch
│   │   ├── toggle-translation-via-switch.patch  # Requires --translate-script-url
│   │   ├── fix-building-with-prunned-binaries.patch  # Disables AI!
│   │   ├── disable-ai-search-shortcuts.patch  # Disables @gemini
│   │   └── ...
│   ├── bromite/
│   │   ├── fingerprinting-flags-client-rects-and-measuretext.patch
│   │   └── flag-fingerprinting-canvas-image-data-noise.patch
│   ├── brave/
│   │   └── chrome-importer-files.patch
│   ├── helium/core/                 # 65+ core modifications
│   │   ├── change-chromium-branding.patch
│   │   ├── add-helium-versioning.patch
│   │   ├── spoof-chrome-ua-brand.patch
│   │   ├── keyboard-shortcuts.patch
│   │   ├── exclude-irrelevant-flags.patch  # HIDES AI FLAGS!
│   │   ├── component-updates.patch  # BLOCKS AI COMPONENTS!
│   │   └── ...
│   ├── helium/settings/
│   │   ├── remove-translate-section.patch
│   │   └── ...
│   ├── helium/ui/                   # 58+ UI patches
│   └── helium/hop/
├── utils/
│   ├── name_substitution.py
│   └── ...
├── resources/
├── flags.gn                         # GN build flags
├── chromium_version.txt
└── revision.txt
```

---

## Patch Flow

```
1. source dev.sh
   └── Loads environment, defines 'he' command

2. he merge
   ├── Reads helium-chromium/patches/series (269 patches)
   ├── Reads patches/series (28 macOS patches)
   └── Combines into patches/series.merged

3. he push
   └── quilt push -a --refresh
       └── Applies all patches to build/src/

4. ./build.sh arm64
   └── gn gen + ninja compile

5. ./sign_and_package_app.sh
   └── Creates signed DMG
```

---

## Critical Patches That Affect Our Goals

### Patches That DISABLE AI Features

| Patch | File | Effect |
|-------|------|--------|
| `helium/core/exclude-irrelevant-flags.patch` | `chrome/browser/about_flags.cc` | Hides AI flags from chrome://flags by adding them to `kExcludedFlags` |
| `ungoogled-chromium/fix-building-with-prunned-binaries.patch` | Multiple BUILD.gn files | Sets `use_on_device_model_service=false`, completely disables on-device AI |
| `ungoogled-chromium/disable-ai-search-shortcuts.patch` | Omnibox code | Removes @gemini, @aimode shortcuts |
| `helium/core/component-updates.patch` | Component updater | Whitelists ONLY CRLSet, blocks AI model downloads |

### Patches That DISABLE Translation

| Patch | File | Effect |
|-------|------|--------|
| `ungoogled-chromium/toggle-translation-via-switch.patch` | `translate_manager.cc` | Requires `--translate-script-url` flag to enable |
| `helium/settings/remove-translate-section.patch` | Settings HTML | Wraps translate UI in `<if expr="False">` |
| `ungoogled-chromium/macos/fix-disabling-safebrowsing.patch` | `chrome_content_browser_client.cc` | Removes TranslateKit sandbox setup |
| `inox-patchset/modify-default-prefs.patch` | Default prefs | Sets `translate::prefs::kOfferTranslateEnabled = false` |
| `iridium-browser/all-add-trk-prefixes-to-possibly-evil-connections.patch` | URL configs | Adds `trk:220:` prefix to translate.googleapis.com (blocks it) |

### Patches That Handle BRANDING

| Patch | File(s) | What It Changes |
|-------|---------|-----------------|
| `helium/core/change-chromium-branding.patch` | `chrome/app/theme/chromium/BRANDING` | Product name, company, bundle ID, team ID |
| `helium/core/add-helium-versioning.patch` | Multiple version files | Version string functions, UI display |
| `helium/core/spoof-chrome-ua-brand.patch` | `user_agent_utils.cc` | User-Agent brand (spoofs as "Google Chrome") |
| `helium/core/replace-default-profile-name.patch` | `profiles_state.cc` | Default profile display name |
| `helium/macos/change-keychain-name.patch` | `keychain_password_mac.mm` | macOS keychain entry name |
| `helium/macos/change-product-dir-name.patch` | `chrome_paths_mac.mm` | ~/Library/Application Support/[name] |

### Patches That Handle KEYBOARD SHORTCUTS

| Patch | File(s) | What It Changes |
|-------|---------|-----------------|
| `helium/core/keyboard-shortcuts.patch` | `global_keyboard_shortcuts_mac.mm` | Cmd+Shift+C → Copy URL, Cmd+Shift+E → Inspect |

---

## Build Flags Analysis

### flags.gn (from helium-chromium)

```gn
build_with_tflite_lib=false           # No TensorFlow Lite
chrome_pgo_phase=0                    # No profile-guided optimization
clang_use_chrome_plugins=false        # No Clang plugins
disable_fieldtrial_testing_config=true # No field trials
enable_hangout_services_extension=false
enable_mdns=false                     # No mDNS
enable_remoting=false                 # No Chrome Remote Desktop
enable_reporting=false                # No crash reporting
enable_service_discovery=false
enable_widevine=true                  # Keep Widevine DRM
exclude_unwind_tables=true
google_api_key=""                     # NO API KEYS
google_default_client_id=""
google_default_client_secret=""
safe_browsing_mode=0                  # Disable Safe Browsing
treat_warnings_as_errors=false
use_official_google_api_keys=false
use_unofficial_version_number=false
```

### flags.macos.gn

```gn
blink_symbol_level=0
enable_iterator_debugging=false
enable_mse_mpeg2ts_stream_parser=true
enable_rust=true
enable_swiftshader=true
enable_updater=false                  # No built-in updater (uses Sparkle)
fatal_linker_warnings=false
ffmpeg_branding="Chrome"              # Full codec support
is_clang=true
is_debug=false
is_official_build=true
proprietary_codecs=true               # H.264, AAC, etc.
symbol_level=1
use_sysroot=false
```

---

## Environment Variables (env.sh)

```bash
_arch           # CPU architecture: "arm64" or "x86_64"
_rust_target    # Rust target: "aarch64-apple-darwin" or "x86_64-apple-darwin"
_root_dir       # Project root directory
_download_cache # Downloaded Chromium sources: build/download_cache
_src_dir        # Extracted Chromium source: build/src
_main_repo      # helium-chromium path
_subs_cache     # Domain substitution cache: build/subs.tar.gz
_namesubs_cache # Name substitution cache: build/namesubs.tar
_clang_dir      # LLVM/Clang path for compilation
```

---

## Component Updates System

Helium proxies all component updates through its own servers and whitelists only specific components.

### Current Allowlist (component-updates.patch)

```cpp
static constexpr auto kAllowedComponents =
  base::MakeFixedFlatSet<std::string_view>(
    base::sorted_unique,
      {
        "hfnkpimlhhgieaddgfemjhofmfblmnib", // CRLSet (certificate revocation)
      }
  );
```

### Component IDs Needed for AI

| Component | ID | Purpose |
|-----------|-----|---------|
| CRLSet | `hfnkpimlhhgieaddgfemjhofmfblmnib` | Certificate revocation (already allowed) |
| OptimizationGuidePredictionModels | `lmelglejhemejginpboagddgdfbepgmp` | Gemini Nano models (NEED TO ADD) |
| TranslateKit | TBD | On-device translation (NOT adding - disabled) |
