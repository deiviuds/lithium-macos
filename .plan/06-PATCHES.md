# PATCHES TO CREATE

## Overview

This document specifies all patches that need to be created for Lithium Browser.

---

## Patch Organization

### In lithium-chromium (Core Fork)

```
helium-chromium/patches/lithium/core/
├── enable-on-device-model.patch      # Enable AI infrastructure
├── restore-ai-flags.patch            # Unhide AI flags
├── allow-ai-components.patch         # Allow model downloads
├── lithium-branding.patch            # Product branding
└── lithium-versioning.patch          # Version system
```

### In lithium-macos (Platform Fork)

```
patches/lithium/macos/
├── keyboard-shortcuts.patch          # Cmd+D/Cmd+Shift+D
├── lithium-keychain.patch            # Keychain name
└── lithium-product-dir.patch         # App Support directory
```

---

## Patch 1: enable-on-device-model.patch

**Location:** `lithium/core/`
**Purpose:** Enable the on-device model service for AI features

### Target File
`build/config/features.gni` or inline override

### Content

```patch
# Enable on-device AI model service
# This overrides fix-building-with-prunned-binaries.patch

--- a/build/config/features.gni
+++ b/build/config/features.gni
@@ -XX,X +XX,X @@
-  use_on_device_model_service = false
+  use_on_device_model_service = is_win || is_mac || is_linux
```

**Alternative:** Add to `flags.gn`:
```gn
use_on_device_model_service = true
```

---

## Patch 2: restore-ai-flags.patch

**Location:** `lithium/core/`
**Purpose:** Remove AI flags from kExcludedFlags so they appear in chrome://flags

### Target File
`chrome/browser/about_flags.cc`

### Flags to Remove from kExcludedFlags

```cpp
// REMOVE these from exclusion (make visible):
"prompt-api-for-gemini-nano",
"prompt-api-for-gemini-nano-multimodal-input",
"summarization-api-for-gemini-nano",
"writer-api-for-gemini-nano",
"rewriter-api-for-gemini-nano",
"proofreader-api-for-gemini-nano",
"optimization-guide-on-device-model",
```

### Flags to KEEP Excluded

```cpp
// Keep these hidden (translation disabled, privacy):
"translation-api",
"translation-api-streaming-by-sentence",
"language-detection-api",
// ... all other Helium exclusions
```

---

## Patch 3: allow-ai-components.patch

**Location:** `lithium/core/`
**Purpose:** Add OptimizationGuidePredictionModels to component allowlist

### Target File
`components/component_updater/component_installer.cc`
(Modified by `helium/core/component-updates.patch`)

### Content

```patch
--- a/components/component_updater/component_installer.cc
+++ b/components/component_updater/component_installer.cc
@@ -XX,X +XX,X @@
   static constexpr auto kAllowedComponents =
     base::MakeFixedFlatSet<std::string_view>(
       base::sorted_unique,
         {
           "hfnkpimlhhgieaddgfemjhofmfblmnib", // CRLSet
+          "lmelglejhemejginpboagddgdfbepgmp", // OptimizationGuidePredictionModels
         }
     );
```

---

## Patch 4: lithium-branding.patch

**Location:** `lithium/core/`
**Purpose:** Replace Helium branding with Lithium

### Target Files

1. `chrome/app/theme/chromium/BRANDING`

```patch
--- a/chrome/app/theme/chromium/BRANDING
+++ b/chrome/app/theme/chromium/BRANDING
@@ -1,10 +1,10 @@
-COMPANY_FULLNAME=The Helium Authors
-COMPANY_SHORTNAME=The Helium Authors
-PRODUCT_FULLNAME=Helium
-PRODUCT_SHORTNAME=Helium
-PRODUCT_INSTALLER_FULLNAME=Helium Installer
-PRODUCT_INSTALLER_SHORTNAME=Helium Installer
-COPYRIGHT=Copyright @LASTCHANGE_YEAR@ The Helium Authors. All rights reserved.
-MAC_BUNDLE_ID=net.imput.helium
+COMPANY_FULLNAME=Lithium Browser
+COMPANY_SHORTNAME=Lithium
+PRODUCT_FULLNAME=Lithium
+PRODUCT_SHORTNAME=Lithium
+PRODUCT_INSTALLER_FULLNAME=Lithium Installer
+PRODUCT_INSTALLER_SHORTNAME=Lithium Installer
+COPYRIGHT=Copyright @LASTCHANGE_YEAR@ Lithium Browser. All rights reserved.
+MAC_BUNDLE_ID=com.lithium.browser
 MAC_CREATOR_CODE=Cr24
-MAC_TEAM_ID=S4Q33XPHB4
+MAC_TEAM_ID=XXXXXXXXXX
```

---

## Patch 5: lithium-versioning.patch

**Location:** `lithium/core/`
**Purpose:** Rename HELIUM version system to LITHIUM

### Target Files

Multiple files with search/replace:
- `HELIUM_MAJOR` → `LITHIUM_MAJOR`
- `HELIUM_MINOR` → `LITHIUM_MINOR`
- `HELIUM_PATCH` → `LITHIUM_PATCH`
- `HELIUM_PLATFORM` → `LITHIUM_PLATFORM`
- `HELIUM_PRODUCT_VERSION` → `LITHIUM_PRODUCT_VERSION`
- `GetHeliumVersionNumber` → `GetLithiumVersionNumber`
- `helium_version` → `lithium_version`
- `kHeliumVersion` → `kLithiumVersion`

### Files Affected

1. `build/apple/tweak_info_plist.py`
2. `base/version_info/version_info_values.h.version`
3. `base/version_info/version_info.h`
4. `chrome/browser/ui/webui/version/version_ui.cc`
5. `components/webui/version/version_ui_constants.cc`
6. `components/webui/version/version_ui_constants.h`
7. `chrome/app/settings_strings.grdp`
8. `components/webui/version/resources/about_version.html`
9. `components/webui/version/resources/about_version.ts`
10. `components/webui/version/resources/about_version.css`
11. `chrome/app/chrome_main_delegate.cc`

---

## Patch 6: keyboard-shortcuts.patch

**Location:** `lithium/macos/`
**Purpose:** Change Cmd+D to focus address bar, Cmd+Shift+D to bookmark

### Target File
`chrome/browser/global_keyboard_shortcuts_mac.mm`

### Content

```patch
--- a/chrome/browser/global_keyboard_shortcuts_mac.mm
+++ b/chrome/browser/global_keyboard_shortcuts_mac.mm
@@ -XX,X +XX,X @@
-      {true,  false, false, false, kVK_ANSI_D,            IDC_BOOKMARK_PAGE},
+      // Lithium: Cmd+D focuses address bar
+      {true,  false, false, false, kVK_ANSI_D,            IDC_FOCUS_LOCATION},
+      // Lithium: Cmd+Shift+D adds bookmark
+      {true,  true,  false, false, kVK_ANSI_D,            IDC_BOOKMARK_PAGE},
```

---

## Patch 7: lithium-keychain.patch

**Location:** `lithium/macos/`
**Purpose:** Update macOS keychain entry name

### Target File
`components/os_crypt/common/keychain_password_mac.mm`

### Content

```patch
--- a/components/os_crypt/common/keychain_password_mac.mm
+++ b/components/os_crypt/common/keychain_password_mac.mm
@@ -XX,X +XX,X @@
-const char kDefaultServiceName[] = "Helium Storage Key";
-const char kDefaultAccountName[] = "Helium";
+const char kDefaultServiceName[] = "Lithium Storage Key";
+const char kDefaultAccountName[] = "Lithium";
```

---

## Patch 8: lithium-product-dir.patch

**Location:** `lithium/macos/`
**Purpose:** Update Application Support directory name

### Target File
`chrome/common/chrome_paths_mac.mm`

### Content

```patch
--- a/chrome/common/chrome_paths_mac.mm
+++ b/chrome/common/chrome_paths_mac.mm
@@ -XX,X +XX,X @@
-      product_dir_name = "net.imput.helium";
+      product_dir_name = "com.lithium.browser";
```

---

## Series File Updates

### helium-chromium patches/series (append at end)

```
# Lithium patches
lithium/core/enable-on-device-model.patch
lithium/core/restore-ai-flags.patch
lithium/core/allow-ai-components.patch
lithium/core/lithium-branding.patch
lithium/core/lithium-versioning.patch
```

### lithium-macos patches/series (append at end)

```
# Lithium patches
lithium/macos/keyboard-shortcuts.patch
lithium/macos/lithium-keychain.patch
lithium/macos/lithium-product-dir.patch
```
