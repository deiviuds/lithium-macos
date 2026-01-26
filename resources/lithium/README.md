# Lithium Browser Resources

This directory contains Lithium-specific branding and icon resources that override Helium's default branding during the build process.

## Directory Structure

```
lithium/
├── app_icon/                    # macOS app icon source files
│   ├── raw.png                  # 1024x1024 source icon
│   ├── app.icns                 # Generated macOS icon bundle
│   ├── Assets.car               # Compiled asset catalog
│   └── Assets.xcassets/         # Xcode asset catalog source
│
├── branding/                    # Product logos and branding
│   ├── product_logo.svg         # Vector logo
│   ├── product_logo.png         # 100% scale logo
│   ├── product_logo_white.png   # White variant (100%)
│   ├── product_logo_200.png     # 200% scale logo
│   ├── product_logo_white_200.png # White variant (200%)
│   ├── product_logo_22_mono.png # Monochrome toolbar icon
│   └── product_logo.icon/       # Chromium vector icon format
│
├── favicons/                    # Browser UI favicons
│   ├── favicon_ntp_16.png       # New Tab Page favicon (16px)
│   └── favicon_ntp_32.png       # New Tab Page favicon (32px)
│
├── lithium_resources.txt        # Resource mapping file
├── generate_assets.sh           # Script to regenerate Assets.car
└── README.md                    # This file
```

## Build Integration

During the build process (`he setup`), the `dev.sh` script:

1. Generates Helium resources (from `helium-chromium/resources/`)
2. Applies platform-specific resources (from `resources/platform_resources.txt`)
3. **Applies Lithium resources** (from `resources/lithium/lithium_resources.txt`) ← **Overrides Helium branding**

The resource mapping is defined in `lithium_resources.txt`, which tells the build system where to copy each Lithium file in the Chromium source tree.

## Regenerating Assets

### Assets.car

The `Assets.car` file must be regenerated whenever `raw.png` changes. This requires **full Xcode** (not just Command Line Tools):

```bash
cd resources/lithium
./generate_assets.sh
```

### app.icns

To regenerate `app.icns` from `raw.png`:

```bash
cd resources/lithium/app_icon

# Create iconset with all required sizes
mkdir -p AppIcon.iconset
sips -z 16 16 raw.png --out AppIcon.iconset/icon_16x16.png
sips -z 32 32 raw.png --out AppIcon.iconset/icon_16x16@2x.png
sips -z 32 32 raw.png --out AppIcon.iconset/icon_32x32.png
sips -z 64 64 raw.png --out AppIcon.iconset/icon_32x32@2x.png
sips -z 128 128 raw.png --out AppIcon.iconset/icon_128x128.png
sips -z 256 256 raw.png --out AppIcon.iconset/icon_128x128@2x.png
sips -z 256 256 raw.png --out AppIcon.iconset/icon_256x256.png
sips -z 512 512 raw.png --out AppIcon.iconset/icon_256x256@2x.png
sips -z 512 512 raw.png --out AppIcon.iconset/icon_512x512.png
sips -z 1024 1024 raw.png --out AppIcon.iconset/icon_512x512@2x.png

# Generate icns
iconutil -c icns AppIcon.iconset -o app.icns

# Cleanup
rm -rf AppIcon.iconset
```

## Icon Specifications

| File | Dimensions | Format | Purpose |
|------|------------|--------|---------|
| `raw.png` | 1024x1024 | PNG RGBA | Source for all generated icons |
| `app.icns` | Multi-size | ICNS | macOS app icon bundle |
| `Assets.car` | Multi-size | Asset Catalog | macOS app asset catalog |
| `product_logo.png` | Variable | PNG | Browser UI logo (100%) |
| `product_logo_200.png` | Variable | PNG | Browser UI logo (200%) |
| `product_logo_22_mono.png` | 22x22 | PNG | Monochrome toolbar icon |
| `favicon_ntp_*.png` | 16x16, 32x32 | PNG | New Tab Page favicon |

## Version

- **Lithium Version:** v0.1-beta
- **Last Updated:** 2026-01-25
