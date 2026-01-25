# TRANSLATION FEATURES ANALYSIS

## Overview

Chrome has THREE distinct translation systems. This document explains each and why Lithium keeps them ALL disabled per user choice.

---

## Translation Systems in Chrome

### 1. Cloud Translation API (Traditional)

| Aspect | Details |
|--------|---------|
| How it works | Text sent to Google servers → translated → returned |
| URL | `translate.googleapis.com` |
| API Key Required | Yes |
| Privacy | Low (all text sent to Google) |
| Offline | No |

### 2. Translator API (Built-in AI, On-Device)

| Aspect | Details |
|--------|---------|
| How it works | Local TranslateKit model performs translation |
| Chrome Flags | `translation-api`, `translation-api-streaming-by-sentence` |
| Component | TranslateKit |
| API Key Required | No |
| Privacy | High (text never leaves device) |
| Offline | Yes (after model download) |

### 3. TranslateKit (On-Device Translation Component)

| Aspect | Details |
|--------|---------|
| How it works | Downloaded language packs for local translation |
| Size | ~50-200MB per language pair |
| API Key Required | No |
| Privacy | High (fully local) |
| Offline | Yes |

---

## How Helium Disables Translation

### 1. Cloud Translation - BLOCKED

**Patch:** `iridium-browser/all-add-trk-prefixes-to-possibly-evil-connections.patch`
```cpp
// Adds "trk:220:" prefix which triggers blocking
"trk:220:translate.googleapis.com"
```

**Patch:** `ungoogled-chromium/toggle-translation-via-switch.patch`
```cpp
// Requires explicit flag to enable
if (!command_line.HasSwitch(translate::switches::kTranslateScriptURL))
  return;  // Block all translation requests
```

**Patch:** `inox-patchset/modify-default-prefs.patch`
```cpp
// Default preference is off
translate::prefs::kOfferTranslateEnabled = false
```

### 2. Translator API (Built-in AI) - HIDDEN

**Patch:** `helium/core/exclude-irrelevant-flags.patch`
```cpp
// Hidden from chrome://flags
"translation-api",
"translation-api-streaming-by-sentence",
```

Comment in patch explains why:
```cpp
// Google's experimental APIs that don't work in Helium
// due to missing model binaries
```

### 3. TranslateKit - DISABLED

**Patch:** `ungoogled-chromium/macos/fix-disabling-safebrowsing.patch`
```cpp
// Removes sandbox setup for TranslateKit
-  if (sandbox_type == sandbox::mojom::Sandbox::kOnDeviceTranslation) {
-    auto translatekit_binary_path = 
-        on_device_translation::ComponentManager::GetInstance()
-            .GetTranslateKitComponentPath();
-    // ... sandbox configuration removed
-  }
```

**Patch:** `ungoogled-chromium/fix-building-with-prunned-binaries.patch`
```gn
use_on_device_model_service = false  // Disables entire on-device framework
```

### 4. UI Removal

**Patch:** `helium/settings/remove-translate-section.patch`
```html
<!-- Wraps translate settings in conditional that's always false -->
<if expr="False">
  <settings-section page-title="$i18n{translatePageTitle}">
  ...
  </settings-section>
</if>
```

---

## Lithium Decision: Keep Translation DISABLED

Per user choice, Lithium will:

1. **NOT** restore Cloud Translation (privacy concern)
2. **NOT** restore Translator API (user preference)
3. **NOT** restore TranslateKit (user preference)
4. **KEEP** all Helium translation-blocking patches

### Patches to KEEP (Not Override)

| Patch | Keep? | Reason |
|-------|-------|--------|
| `toggle-translation-via-switch.patch` | Yes | Blocks cloud translation |
| `all-add-trk-prefixes-to-possibly-evil-connections.patch` | Yes | Blocks translate API URL |
| `modify-default-prefs.patch` | Yes | Keeps translate off by default |
| `remove-translate-section.patch` | Yes | Hides translate UI |
| `fix-disabling-safebrowsing.patch` (TranslateKit part) | Yes | Keeps TranslateKit disabled |

### Flags to KEEP Hidden

These will remain in `kExcludedFlags`:
```cpp
"translation-api",
"translation-api-streaming-by-sentence",
```

---

## Future Option: Enable On-Device Translation

If user later wants on-device translation, these patches would be needed:

1. **enable-on-device-model.patch** - Already creating for AI
2. **restore-ai-flags.patch** - Add translation flags to unhide list
3. **enable-translatekit-sandbox.patch** - Restore macOS sandbox setup
4. **enable-translate-ui.patch** - Remove `<if expr="False">` wrapper
5. **allow-translation-components.patch** - Add TranslateKit to allowlist

This is documented for future reference but NOT being implemented now.
