# LITHIUM BROWSER - PLAN INDEX

## Documents

| File | Description |
|------|-------------|
| [00-OVERVIEW.md](00-OVERVIEW.md) | Project overview, configuration, features matrix |
| [01-ARCHITECTURE.md](01-ARCHITECTURE.md) | Helium's patch system, directory structure, patch flow |
| [02-AI-FEATURES.md](02-AI-FEATURES.md) | AI feature dependencies, flags, component requirements |
| [03-TRANSLATION.md](03-TRANSLATION.md) | Translation systems analysis, why keeping disabled |
| [04-BRANDING.md](04-BRANDING.md) | Branding specification, files to modify |
| [05-KEYBOARD-SHORTCUTS.md](05-KEYBOARD-SHORTCUTS.md) | Keyboard shortcut changes |
| [06-PATCHES.md](06-PATCHES.md) | All patches to create with content |
| [07-GIT-WORKFLOW.md](07-GIT-WORKFLOW.md) | Forking strategy, upstream sync |
| [08-QUILT-WORKFLOW.md](08-QUILT-WORKFLOW.md) | Patch management with quilt |
| [09-AI-PATCH-FIXING.md](09-AI-PATCH-FIXING.md) | AI-assisted conflict resolution |
| [10-BUILD-WORKFLOW.md](10-BUILD-WORKFLOW.md) | Building and development |
| [11-CHECKLIST.md](11-CHECKLIST.md) | Implementation checklist |
| [12-REFERENCE-PATCHES.md](12-REFERENCE-PATCHES.md) | Complete Helium patches reference |

---

## Quick Reference

### Key Decisions

| Decision | Choice |
|----------|--------|
| Fork Strategy | Two forks (lithium-chromium + lithium-macos) |
| AI Features | Enable Gemini Nano, Prompt, Summarizer, Writer, Rewriter, Proofreader |
| Translation | Keep disabled |
| @gemini shortcuts | Keep disabled |
| Language Detector | Skip (no ScreenAI) |
| Apple Team ID | Placeholder |

### Patches to Create

**In lithium-chromium:**
1. `lithium/core/enable-on-device-model.patch`
2. `lithium/core/restore-ai-flags.patch`
3. `lithium/core/allow-ai-components.patch`
4. `lithium/core/lithium-branding.patch`
5. `lithium/core/lithium-versioning.patch`

**In lithium-macos:**
1. `lithium/macos/keyboard-shortcuts.patch`
2. `lithium/macos/lithium-keychain.patch`
3. `lithium/macos/lithium-product-dir.patch`

### Build Commands

```bash
source dev.sh      # Initialize
he merge           # Merge series
he push            # Apply patches
./build.sh arm64   # Build
./sign_and_package_app.sh  # Package
```

---

## Next Steps

1. Review all plan documents
2. Proceed with implementation using [11-CHECKLIST.md](11-CHECKLIST.md)
3. Use [09-AI-PATCH-FIXING.md](09-AI-PATCH-FIXING.md) for any conflicts

---

*Generated for Lithium Browser project - deiviuds/lithium-macos*
