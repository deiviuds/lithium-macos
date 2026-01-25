# REFERENCE: HELIUM PATCHES ANALYSIS

## Complete Patch Categories

This document provides a reference of all Helium patches organized by category.

---

## Privacy & De-Googling Patches

### ungoogled-chromium/ (71+ patches)

| Patch | Purpose |
|-------|---------|
| disable-crash-reporter.patch | Remove crash reporting |
| disable-google-host-detection.patch | Stop Google host checks |
| toggle-translation-via-switch.patch | Disable translation unless flag set |
| disable-untraceable-urls.patch | Remove untraceable URL pings |
| disable-profile-avatar-downloading.patch | No Google avatar downloads |
| disable-gcm.patch | Disable Google Cloud Messaging |
| disable-domain-reliability.patch | No domain reliability reporting |
| block-trk-and-subdomains.patch | Block tracking subdomains |
| disable-gaia.patch | Disable Google Account integration |
| disable-fonts-googleapis-references.patch | No Google Fonts |
| disable-webstore-urls.patch | Modify webstore URLs |
| disable-webrtc-log-uploader.patch | No WebRTC log upload |
| fix-building-with-prunned-binaries.patch | **DISABLES AI** |
| disable-network-time-tracker.patch | No network time sync |
| disable-mei-preload.patch | No media engagement preload |
| fix-building-without-safebrowsing.patch | Safe browsing removal |
| disable-privacy-sandbox.patch | Disable Privacy Sandbox |
| disable-ai-search-shortcuts.patch | **DISABLES @gemini** |
| ... | (many more) |

### iridium-browser/ (5 patches)

| Patch | Purpose |
|-------|---------|
| safe-browsing-disable-reporting.patch | No safe browsing reports |
| all-add-trk-prefixes-to-possibly-evil-connections.patch | **BLOCKS translate API** |
| updater-disable-auto-update.patch | No auto-update pings |
| browser-disable-profile-auto-import-on-first-run.patch | No auto import |

### inox-patchset/ (6 patches)

| Patch | Purpose |
|-------|---------|
| fix-building-without-safebrowsing.patch | Safe browsing build fix |
| disable-autofill-download-manager.patch | No autofill downloads |
| disable-update-pings.patch | No update checks |
| disable-rlz.patch | Disable RLZ tracking |
| modify-default-prefs.patch | **Sets translate=false** |
| disable-battery-status-service.patch | No battery API |

### bromite/ (4 patches)

| Patch | Purpose |
|-------|---------|
| disable-fetching-field-trials.patch | No field trials |
| fingerprinting-flags-client-rects-and-measuretext.patch | Anti-fingerprinting |
| flag-max-connections-per-host.patch | Connection control |
| flag-fingerprinting-canvas-image-data-noise.patch | Canvas noise |

---

## Helium Core Patches

### helium/core/ (65+ patches)

| Patch | Purpose | Lithium Action |
|-------|---------|----------------|
| change-chromium-branding.patch | Product branding | **OVERRIDE** |
| add-helium-versioning.patch | Version system | **OVERRIDE** |
| spoof-chrome-ua-brand.patch | UA spoofing | Keep |
| keyboard-shortcuts.patch | Custom shortcuts | **EXTEND** |
| exclude-irrelevant-flags.patch | **HIDES AI FLAGS** | **OVERRIDE** |
| component-updates.patch | **BLOCKS AI COMPONENTS** | **OVERRIDE** |
| services-prefs.patch | Helium services prefs | Keep |
| onboarding-page.patch | First-run page | Keep |
| ublock-*.patch (6) | uBlock integration | Keep |
| disable-live-caption-completely.patch | No live caption | Keep |
| disable-history-clusters.patch | No history AI | Keep |
| disable-ad-topics-and-etc.patch | No ad topics | Keep |
| ... | (many more) | Keep |

### helium/settings/ (20 patches)

| Patch | Purpose | Lithium Action |
|-------|---------|----------------|
| remove-translate-section.patch | Hide translate UI | Keep (translation disabled) |
| setup-behavior-settings-page.patch | Settings layout | Keep |
| remove-autofill.patch | Hide autofill | Keep |
| remove-profile-page-sections.patch | Simplify profile | Keep |
| privacy-page-tweaks.patch | Privacy settings | Keep |
| ... | (many more) | Keep |

### helium/ui/ (58 patches)

| Patch | Purpose |
|-------|---------|
| layout-constants.patch | UI dimensions |
| location-bar.patch | Address bar style |
| tabs.patch | Tab appearance |
| toolbar.patch | Toolbar layout |
| omnibox.patch | Search box style |
| app-menu-*.patch | Menu appearance |
| side-panel.patch | Side panel tweaks |
| helium-logo-icons.patch | Logo icons |
| helium-color-scheme.patch | Color theme |
| ... | (many more) |

---

## macOS-Specific Patches

### ungoogled-chromium/macos/ (13 patches)

| Patch | Purpose | Lithium Action |
|-------|---------|----------------|
| build-bindgen.patch | Rust build fix | Keep |
| disable-clang-version-check.patch | Build fix | Keep |
| disable-crashpad-handler.patch | No crashpad | Keep |
| fix-disabling-safebrowsing.patch | **REMOVES TranslateKit** | Keep (translation disabled) |
| fix-build-with-rust.patch | Rust support | Keep |
| ... | (many more) | Keep |

### helium/macos/ (8 patches)

| Patch | Purpose | Lithium Action |
|-------|---------|----------------|
| change-keychain-name.patch | Keychain entry | **OVERRIDE** |
| change-product-dir-name.patch | App Support dir | **OVERRIDE** |
| clean-main-menu.patch | Menu cleanup | Keep |
| disable-immersive-fullscreen.patch | Fullscreen fix | Keep |
| fix-pwa-shims.patch | PWA support | Keep |
| ... | (many more) | Keep |

### rebel/macos/ + helium/macos/updater/ (4 patches)

| Patch | Purpose |
|-------|---------|
| sparkle-integration.patch | Sparkle updater |
| sparkle2-integration.patch | Sparkle 2 support |
| fixup-sparkle-glue.patch | Glue code fixes |
| disable-default-updater.patch | No Chrome updater |

---

## Patches Lithium Overrides

| Original Patch | Lithium Patch | Purpose |
|---------------|---------------|---------|
| exclude-irrelevant-flags.patch | restore-ai-flags.patch | Unhide AI flags |
| fix-building-with-prunned-binaries.patch | enable-on-device-model.patch | Enable AI service |
| component-updates.patch | allow-ai-components.patch | Allow model downloads |
| change-chromium-branding.patch | lithium-branding.patch | Lithium brand |
| add-helium-versioning.patch | lithium-versioning.patch | Lithium version |
| keyboard-shortcuts.patch | keyboard-shortcuts.patch | Cmd+D change |
| change-keychain-name.patch | lithium-keychain.patch | Keychain name |
| change-product-dir-name.patch | lithium-product-dir.patch | Product dir |

---

## Patches Lithium Keeps Unchanged

All patches not listed above are kept as-is from Helium, providing:
- Privacy protections
- UI improvements
- Build fixes
- uBlock integration
- Sparkle updater
