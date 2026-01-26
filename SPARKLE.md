# Sparkle Auto-Update Framework

## Status: DISABLED

Sparkle is currently disabled in Lithium. The `enable_sparkle` build flag is set to `false`.

## What is Sparkle?

[Sparkle](https://sparkle-project.org/) is an open-source software update framework for macOS applications distributed **outside the Mac App Store**. It provides:

- Automatic update checking on a configurable schedule
- Delta updates (only download what changed)
- DSA/EdDSA signature verification for security
- User-friendly update notifications
- Seamless background installation

## Why is it in the codebase?

The Sparkle integration patches came from the **Rebel** project (another Chromium fork) and were adapted for Helium. The patches add:

1. `sparkle_glue.h/mm` - C++/Objective-C bridge to Sparkle framework
2. `VersionUpdaterSparkle` - Integration with chrome://settings/help page
3. Build system integration for the Sparkle.framework

## Why is it disabled?

1. **No update infrastructure** - Sparkle requires hosting appcast XML files and signed update packages
2. **Code signing required** - Updates must be signed with a Developer ID certificate
3. **Development focus** - Lithium is primarily for local development/testing
4. **Complexity** - Enabling Sparkle requires significant setup

## Patches involved

These patches are applied in order (the first one defines the buildflag):

| Patch | Purpose |
|-------|---------|
| `lithium/macos/add-enable-sparkle-buildflag.patch` | Defines `enable_sparkle=false` buildflag |
| `rebel/macos/sparkle-integration.patch` | Core Sparkle integration (from Rebel project) |
| `helium/macos/updater/fixup-sparkle-glue.patch` | Namespace fixes (rebel -> helium) |
| `helium/macos/updater/sparkle2-integration.patch` | Sparkle 2.x API updates |
| `helium/macos/updater/disable-default-updater.patch` | Disables Chrome's default updater |

## How to enable Sparkle (future)

If you want to enable automatic updates for Lithium:

### 1. Set the build flag

Edit `chrome/browser/buildflags.gni`:
```gn
enable_sparkle = true
```

Or modify `add-enable-sparkle-buildflag.patch` to set it to `true`.

### 2. Configure Sparkle

You'll need to set up:

- **Appcast URL** - XML feed describing available updates
- **Signing keys** - EdDSA keys for update verification
- **Update server** - Host for distributing .dmg or .zip updates

### 3. Code signing

The app and updates must be signed with an Apple Developer ID certificate for Gatekeeper compatibility.

### 4. Info.plist keys

Add to the app's Info.plist:
```xml
<key>SUFeedURL</key>
<string>https://your-server.com/appcast.xml</string>
<key>SUPublicEDKey</key>
<string>your-base64-encoded-public-key</string>
```

## Resources

- [Sparkle Documentation](https://sparkle-project.org/documentation/)
- [Sparkle GitHub](https://github.com/sparkle-project/Sparkle)
- [Publishing an Update](https://sparkle-project.org/documentation/publishing/)

## Removing Sparkle entirely

If you want to completely remove Sparkle from the codebase, remove these patches from `patches/series`:

```
lithium/macos/add-enable-sparkle-buildflag.patch
rebel/macos/sparkle-integration.patch
helium/macos/updater/fixup-sparkle-glue.patch
helium/macos/updater/sparkle2-integration.patch
helium/macos/updater/disable-default-updater.patch
```

Note: This will also remove the update UI from chrome://settings/help on macOS.
