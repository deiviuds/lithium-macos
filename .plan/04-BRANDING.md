# BRANDING SPECIFICATION

## Overview

Complete rebranding from Helium to Lithium across all user-visible strings, identifiers, and assets.

---

## Branding Values

| Field | Helium Value | Lithium Value |
|-------|-------------|---------------|
| COMPANY_FULLNAME | The Helium Authors | Lithium Browser |
| COMPANY_SHORTNAME | The Helium Authors | Lithium |
| PRODUCT_FULLNAME | Helium | Lithium |
| PRODUCT_SHORTNAME | Helium | Lithium |
| PRODUCT_INSTALLER_FULLNAME | Helium Installer | Lithium Installer |
| PRODUCT_INSTALLER_SHORTNAME | Helium Installer | Lithium Installer |
| COPYRIGHT | Copyright @LASTCHANGE_YEAR@ The Helium Authors. All rights reserved. | Copyright @LASTCHANGE_YEAR@ Lithium Browser. All rights reserved. |
| MAC_BUNDLE_ID | net.imput.helium | com.lithium.browser |
| MAC_TEAM_ID | S4Q33XPHB4 | XXXXXXXXXX (placeholder) |
| Keychain Service | Helium Storage Key | Lithium Storage Key |
| Keychain Account | Helium | Lithium |
| Product Directory | net.imput.helium | com.lithium.browser |

---

## Files to Modify

### 1. BRANDING File

**Original (Helium):** `helium/core/change-chromium-branding.patch`
**Target File:** `chrome/app/theme/chromium/BRANDING`

```diff
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

### 2. Version System

**Original (Helium):** `helium/core/add-helium-versioning.patch`
**Changes Required:**

| Original | Replace With |
|----------|--------------|
| `HELIUM_MAJOR` | `LITHIUM_MAJOR` |
| `HELIUM_MINOR` | `LITHIUM_MINOR` |
| `HELIUM_PATCH` | `LITHIUM_PATCH` |
| `HELIUM_PLATFORM` | `LITHIUM_PLATFORM` |
| `HELIUM_PRODUCT_VERSION` | `LITHIUM_PRODUCT_VERSION` |
| `GetHeliumVersionNumber()` | `GetLithiumVersionNumber()` |
| `helium_version` | `lithium_version` |
| `kHeliumVersion` | `kLithiumVersion` |

**Files Affected:**
- `build/apple/tweak_info_plist.py`
- `base/version_info/version_info_values.h.version`
- `base/version_info/version_info.h`
- `chrome/browser/ui/webui/version/version_ui.cc`
- `components/webui/version/version_ui_constants.cc`
- `components/webui/version/version_ui_constants.h`
- `chrome/app/settings_strings.grdp`
- `components/webui/version/resources/about_version.html`
- `components/webui/version/resources/about_version.ts`
- `components/webui/version/resources/about_version.css`
- `chrome/app/chrome_main_delegate.cc`

### 3. Keychain Name (macOS)

**Original (Helium):** `helium/macos/change-keychain-name.patch`
**Target File:** `components/os_crypt/common/keychain_password_mac.mm`

```diff
-const char kDefaultServiceName[] = "Helium Storage Key";
-const char kDefaultAccountName[] = "Helium";
+const char kDefaultServiceName[] = "Lithium Storage Key";
+const char kDefaultAccountName[] = "Lithium";
```

### 4. Product Directory (macOS)

**Original (Helium):** `helium/macos/change-product-dir-name.patch`
**Target File:** `chrome/common/chrome_paths_mac.mm`

```diff
-      product_dir_name = "net.imput.helium";
+      product_dir_name = "com.lithium.browser";
```

### 5. User-Agent Brand

**Original (Helium):** `helium/core/spoof-chrome-ua-brand.patch`
**Target File:** `components/embedder_support/user_agent_utils.cc`

**Decision:** Keep spoofing as "Google Chrome" for compatibility
```cpp
return GenerateBrandVersionList(major_version_number, "Google Chrome", brand_version, ...);
```

This ensures websites that check for Chrome work correctly.

---

## Resources to Create/Update

### Icon Assets

| File | Description | Size/Format |
|------|-------------|-------------|
| `resources/assets/app.icns` | macOS app icon | .icns (multiple sizes) |
| `resources/assets/AppIcon.icon/` | Icon source | SVG + PNG |
| `resources/assets/Assets.xcassets/` | Xcode assets | .xcassets |
| `resources/assets/Assets.car` | Compiled assets | .car |

### DMG Configuration

**File:** `resources/dmg.json`

Update background image text, window title, and any Helium references.

---

## Version File

**File:** `revision.txt`

```
1.0.0.1
```

Format: `MAJOR.MINOR.PATCH.PLATFORM`

---

## Component Services Branding

The `component-updates.patch` and `helium_services` code may need updates:

### Helium Services References

Files that reference "Helium" in helium_services:
- `components/helium_services/helium_services_helpers.cc`
- `components/helium_services/helium_services_helpers.h`
- `components/helium_services/pref_names.h`
- `components/helium_services/schema.h`

**Decision:** Keep `helium_services` component name internally for compatibility, only change user-visible strings.

---

## Checklist

- [ ] BRANDING file updated
- [ ] Version system renamed (HELIUM → LITHIUM)
- [ ] Keychain names updated
- [ ] Product directory updated
- [ ] Icons created
- [ ] DMG config updated
- [ ] revision.txt created with 1.0.0.1
