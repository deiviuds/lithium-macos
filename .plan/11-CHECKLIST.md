# IMPLEMENTATION CHECKLIST

## Phase 1: Repository Setup

### GitHub Setup
- [ ] Fork `imputnet/helium` → `deiviuds/lithium-chromium`
- [ ] Fork `imputnet/helium-macos` → `deiviuds/lithium-macos`
- [ ] Clone lithium-macos locally
- [ ] Update .gitmodules to point to lithium-chromium
- [ ] Add upstream remotes to both repos
- [ ] Configure branch protection rules

### Local Setup
- [ ] Install prerequisites (brew packages)
- [ ] Clone with submodules
- [ ] Verify `source dev.sh` works
- [ ] Verify `he merge` works
- [ ] Verify `he push` works (with original patches)

---

## Phase 2: Create Core Patches (in lithium-chromium)

### Patch: enable-on-device-model.patch
- [ ] Create `patches/lithium/core/` directory
- [ ] Write patch to set `use_on_device_model_service=true`
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: restore-ai-flags.patch
- [ ] Analyze current kExcludedFlags content
- [ ] Identify exact flags to remove from exclusion
- [ ] Write patch removing AI flags from kExcludedFlags
- [ ] Keep translation flags excluded
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: allow-ai-components.patch
- [ ] Find OptimizationGuidePredictionModels component ID
- [ ] Write patch adding to kAllowedComponents
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: lithium-branding.patch
- [ ] Write BRANDING file changes
- [ ] Update company name, product name
- [ ] Update bundle ID to com.lithium.browser
- [ ] Use placeholder for Team ID
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: lithium-versioning.patch
- [ ] Search/replace HELIUM → LITHIUM in version files
- [ ] Update all version-related functions
- [ ] Update UI strings
- [ ] Add to series file
- [ ] Test applies cleanly

---

## Phase 3: Create macOS Patches (in lithium-macos)

### Patch: keyboard-shortcuts.patch
- [ ] Create `patches/lithium/macos/` directory
- [ ] Analyze current keyboard-shortcuts.patch
- [ ] Write patch for Cmd+D → IDC_FOCUS_LOCATION
- [ ] Write patch for Cmd+Shift+D → IDC_BOOKMARK_PAGE
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: lithium-keychain.patch
- [ ] Write patch updating keychain service name
- [ ] Write patch updating keychain account name
- [ ] Add to series file
- [ ] Test applies cleanly

### Patch: lithium-product-dir.patch
- [ ] Write patch updating product directory name
- [ ] Add to series file
- [ ] Test applies cleanly

---

## Phase 4: Update Series Files

### helium-chromium patches/series
- [ ] Add lithium/core/enable-on-device-model.patch
- [ ] Add lithium/core/restore-ai-flags.patch
- [ ] Add lithium/core/allow-ai-components.patch
- [ ] Add lithium/core/lithium-branding.patch
- [ ] Add lithium/core/lithium-versioning.patch

### lithium-macos patches/series
- [ ] Add lithium/macos/keyboard-shortcuts.patch
- [ ] Add lithium/macos/lithium-keychain.patch
- [ ] Add lithium/macos/lithium-product-dir.patch

---

## Phase 5: Resources & Configuration

### Version File
- [ ] Create revision.txt with 1.0.0.1

### Build Flags
- [ ] Verify flags.macos.gn is correct
- [ ] Consider adding use_on_device_model_service if not in patch

### Icons (Optional for first build)
- [ ] Create Lithium app icon
- [ ] Update app.icns
- [ ] Update Assets.xcassets
- [ ] Compile Assets.car

### DMG Configuration
- [ ] Update dmg.json with Lithium branding

---

## Phase 6: Documentation

### Create Files
- [ ] AI_PATCH_FIXING.md
- [ ] sync-upstream.sh
- [ ] README.md
- [ ] CHANGELOG.md (optional)

---

## Phase 7: Test Full Build

### Patch Application
- [ ] `he pop` succeeds
- [ ] `he merge` succeeds
- [ ] `he push` applies all patches cleanly

### Compilation
- [ ] `./build.sh arm64` completes
- [ ] No critical errors

### Verification
- [ ] App launches
- [ ] Branding shows "Lithium"
- [ ] Cmd+D focuses address bar
- [ ] Cmd+Shift+D opens bookmark dialog
- [ ] AI flags visible in chrome://flags
- [ ] Keychain shows "Lithium Storage Key"
- [ ] App Support folder is "com.lithium.browser"

### Packaging
- [ ] `./sign_and_package_app.sh` creates DMG
- [ ] DMG installs correctly
- [ ] Installed app works

---

## Phase 8: Git Commit & Push

### Commit Structure
- [ ] Initial commit: Base structure from helium-macos
- [ ] Commit: Update submodule to lithium-chromium
- [ ] Commit: Add Lithium core patches
- [ ] Commit: Add Lithium macOS patches
- [ ] Commit: Add resources and documentation

### Push
- [ ] Push lithium-chromium changes
- [ ] Push lithium-macos changes
- [ ] Update submodule reference
- [ ] Create v1.0.0 tag

---

## Success Criteria

All items checked:
- [ ] All patches apply without errors
- [ ] Browser builds and runs
- [ ] All branding shows "Lithium"
- [ ] Keyboard shortcuts work as specified
- [ ] AI flags are visible (not hidden)
- [ ] DMG package works
