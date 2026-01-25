# LITHIUM BROWSER - COMPLETE PROJECT PLAN

## Executive Summary

Lithium Browser is a privacy-focused Chromium fork based on [helium-macos](https://github.com/imputnet/helium-macos) that re-enables Chrome's native client-side AI features while maintaining Helium's privacy protections.

### Project Goals

1. **Re-enable Chrome Native AI Features** - Gemini Nano, Prompt API, Summarizer, Writer, Rewriter, Proofreader
2. **Custom Keyboard Shortcuts** - Cmd+D → Focus address bar, Cmd+Shift+D → Bookmark
3. **Complete Rebranding** - From Helium to Lithium
4. **Maintainable Architecture** - Easy to sync with upstream Helium updates
5. **Privacy Preservation** - Keep all Helium privacy protections intact

---

## Project Configuration

| Setting | Value |
|---------|-------|
| GitHub User | `deiviuds` |
| Platform Repo | `deiviuds/lithium-macos` |
| Core Repo | `deiviuds/lithium-chromium` |
| Fork Strategy | Two forks (recommended) |
| Target Architecture | macOS arm64 only |
| Apple Team ID | Placeholder (XXXXXXXXXX) - unsigned local builds |
| Bundle ID | `com.lithium.browser` |
| Product Name | Lithium |
| Company | Lithium Browser |
| Keychain Service | Lithium Storage Key |
| Product Directory | com.lithium.browser |

---

## Features Matrix

### ENABLED Features

| Feature | Description | Technical Requirement |
|---------|-------------|----------------------|
| Gemini Nano | Base on-device LLM (~1-2GB model) | `use_on_device_model_service=true` |
| Prompt API | Direct access to Gemini Nano for natural language | Unhide `prompt-api-for-gemini-nano` flag |
| Summarizer API | Summarize text using Gemini Nano | Unhide `summarization-api-for-gemini-nano` flag |
| Writer API | Create new content based on writing tasks | Unhide `writer-api-for-gemini-nano` flag |
| Rewriter API | Refine existing text (longer/shorter/tone) | Unhide `rewriter-api-for-gemini-nano` flag |
| Proofreader API | Grammar and readability improvement | Unhide `proofreader-api-for-gemini-nano` flag |
| Cmd+D → Address bar | Focus address bar (browser standard) | Modify keyboard shortcuts patch |
| Cmd+Shift+D → Bookmark | Add bookmark (moved from Cmd+D) | Modify keyboard shortcuts patch |
| Full Lithium Branding | Complete rebrand of all visible strings | Multiple branding patches |

### DISABLED Features (Privacy/User Choice)

| Feature | Reason | Source |
|---------|--------|--------|
| Language Detector API | Requires complex ScreenAI restoration (~90 lines) | User choice - skip |
| Translator API | User preference | User choice - disabled |
| Cloud Translation | Privacy - sends text to Google servers | Keep Helium behavior |
| @gemini/@aimode shortcuts | User preference | Keep Helium behavior |
| Google Sync | Privacy - syncs to Google | Helium default |
| Safe Browsing | Privacy - sends URLs to Google | Helium default |
| Google Lens | Privacy - cloud AI feature | Helium default |
| History Embeddings | Privacy - could leak browsing data | Helium default |

---

## API Key Requirements

| Feature | API Key Needed? | Works Offline? |
|---------|----------------|----------------|
| Gemini Nano | No | Yes (after model download) |
| Prompt API | No | Yes |
| Summarizer API | No | Yes |
| Writer API | No | Yes |
| Rewriter API | No | Yes |
| Proofreader API | No | Yes |
| Cloud Translation | Yes (disabled) | No |

**All enabled AI features are fully on-device and require no API keys.**

---

## Build Configuration

| Setting | Value |
|---------|-------|
| Target | macOS arm64 (Apple Silicon) |
| Code Signing | Unsigned (local development) |
| Initial Build | Local testing |
| CI/CD | GitHub Actions (later) |

### Unsigned Build Notes

- No Apple Developer account required for local testing
- App will show "unidentified developer" warning on first launch
- Bypass with: Right-click → Open → Open
- Full signing can be added later with Apple Developer enrollment

---

## Repository Structure

### GitHub Organization

```
deiviuds/
├── lithium-chromium          # Fork of imputnet/helium
│   ├── patches/
│   │   ├── series            # Modified to include lithium patches
│   │   ├── helium/           # Original helium patches
│   │   ├── ungoogled-chromium/
│   │   └── lithium/          # NEW: Lithium core patches
│   │       └── core/
│   │           ├── enable-on-device-model.patch
│   │           ├── restore-ai-flags.patch
│   │           ├── allow-ai-components.patch
│   │           ├── lithium-branding.patch
│   │           └── lithium-versioning.patch
│   └── utils/
│
└── lithium-macos             # Fork of imputnet/helium-macos
    ├── helium-chromium/      # Submodule → deiviuds/lithium-chromium
    ├── patches/
    │   ├── series            # Modified to include lithium patches
    │   ├── helium/macos/     # Original macos patches
    │   └── lithium/          # NEW: Lithium macOS patches
    │       └── macos/
    │           ├── keyboard-shortcuts.patch
    │           ├── lithium-keychain.patch
    │           └── lithium-product-dir.patch
    ├── resources/
    │   └── assets/           # Lithium icons
    ├── dev.sh
    ├── build.sh
    ├── env.sh
    ├── flags.macos.gn
    ├── revision.txt          # 1.0.0.1
    ├── AI_PATCH_FIXING.md
    ├── sync-upstream.sh
    └── README.md
```

---

## Success Metrics

### Patch Application
- [ ] All patches apply cleanly (`he push` succeeds)

### Build
- [ ] Browser builds successfully (`./build.sh arm64`)
- [ ] Unsigned app launches on macOS

### Branding Verification
- [ ] About page shows "Lithium" (chrome://settings/help)
- [ ] Version page shows "Lithium" (chrome://version)
- [ ] Window title shows "Lithium"
- [ ] Keychain entry shows "Lithium Storage Key"
- [ ] App Support folder is "com.lithium.browser"

### Keyboard Shortcuts
- [ ] Cmd+D focuses address bar
- [ ] Cmd+Shift+D adds bookmark

### AI Features
- [ ] AI flags visible in chrome://flags:
  - [ ] prompt-api-for-gemini-nano
  - [ ] summarization-api-for-gemini-nano
  - [ ] writer-api-for-gemini-nano
  - [ ] rewriter-api-for-gemini-nano
  - [ ] proofreader-api-for-gemini-nano
- [ ] AI model downloads work via component updater

### Privacy (Unchanged from Helium)
- [ ] Translation features remain disabled
- [ ] @gemini shortcuts remain disabled
- [ ] No Google sync options
- [ ] Safe browsing disabled
