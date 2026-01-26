# Lithium Browser - macOS

Privacy-focused Chromium fork based on [Helium](https://github.com/imputnet/helium) with **native AI features re-enabled**.

## Features

Lithium Browser re-enables Chrome's on-device AI capabilities while maintaining Helium's privacy protections:

- **Gemini Nano** - On-device LLM (~1-2GB model)
- **Prompt API** - Direct access to Gemini Nano
- **Summarizer API** - Text summarization
- **Writer API** - Content generation
- **Rewriter API** - Text refinement
- **Proofreader API** - Grammar checking

All AI features run **completely on-device** - no API keys required, works offline after initial model download.

### Additional Changes

- **Cmd+D** focuses address bar (like other browsers)
- **Cmd+Shift+D** adds bookmark
- Complete Lithium branding

## Building

### Prerequisites

- macOS (Apple Silicon recommended)
- Xcode Command Line Tools
- ~100GB disk space
- 16GB+ RAM

### Quick Start

```bash
# Clone with submodule
git clone --recursive https://github.com/deiviuds/lithium-macos.git
cd lithium-macos

# Setup environment
source dev.sh

# Full setup (downloads Chromium, applies patches, configures build)
he setup

# Build for Apple Silicon
./build.sh arm64

# Run the built browser
he run
```

### Development Workflow

```bash
source dev.sh      # Load environment (required first)
he merge           # Merge patch series
he push            # Apply all patches
he pop             # Remove all patches
he build           # Build browser
he run             # Run development build
he reset           # Clean everything
```

## Upstream Sync

To sync with upstream Helium:

```bash
./sync-upstream.sh
```

If patches fail after syncing, see [AI_PATCH_FIXING.md](AI_PATCH_FIXING.md).

## Project Structure

```
lithium-macos/
├── helium-chromium/         # Submodule: core cross-platform patches
│   └── patches/lithium/core/  # Lithium AI & branding patches
├── patches/
│   ├── series               # Patch application order
│   └── lithium/macos/       # macOS-specific Lithium patches
├── dev.sh                   # Development environment
├── build.sh                 # Full build script
├── flags.macos.gn           # macOS build flags
└── .plan/                   # Project documentation
```

## Verification

After building, verify:

1. **AI Flags** - `chrome://flags` shows:
   - `prompt-api-for-gemini-nano`
   - `summarization-api-for-gemini-nano`
   - `writer-api-for-gemini-nano`
   - `rewriter-api-for-gemini-nano`
   - `proofreader-api-for-gemini-nano`

2. **Branding** - `chrome://settings/help` shows "Lithium"

3. **Shortcuts**:
   - Cmd+D focuses address bar
   - Cmd+Shift+D adds bookmark

4. **Keychain** - Entry shows "Lithium Storage Key"

## Privacy

Lithium inherits all of Helium's privacy protections:
- No Google Sync
- No Safe Browsing
- No telemetry
- Blocked tracking domains
- Privacy-respecting defaults

Translation features remain **disabled** (user preference).

## Credits

- [Helium](https://github.com/imputnet/helium) - Base browser
- [ungoogled-chromium](https://github.com/ungoogled-software/ungoogled-chromium) - Privacy patches
- [Chromium](https://www.chromium.org/) - Browser engine

## License

GPL-3.0. See [LICENSE](LICENSE).
