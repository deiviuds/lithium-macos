# Rust Toolchain Configuration for Lithium Browser

## Overview

Lithium Browser uses **Chromium's prebuilt Rust toolchain** instead of rust-lang.org's nightly releases. This is required for Chromium 144.x+ which builds the Rust standard library from source.

## Why Chromium's Rust Package?

Chromium 144.x+ requires **vendored Rust crate dependencies** to build the standard library from source:
- `libc-0.2.177`
- `compiler_builtins`
- `addr2line`, `adler2`, `cfg-if`, etc.

The official rust-lang.org nightly packages do **NOT** include these vendor dependencies - only the core stdlib source. Chromium's packages include everything needed.

## Package Details

**Current Version**: `11339a0ef5ed586bb7ea4f85a9b7287880caac3a-1-llvmorg-22-init-14273-gea10026b`

**Download URL**: 
```
https://commondatastorage.googleapis.com/chromium-browser-clang/Mac_arm64/rust-toolchain-<version>.tar.xz
```

**What's Included**:
- `bin/rustc`, `bin/cargo`, `bin/rustfmt`, `bin/bindgen`
- `lib/rustlib/src/rust/library/` - Full Rust stdlib source
- `lib/rustlib/src/rust/library/vendor/` - **All vendored dependencies**
- `VERSION` file in Chromium's expected format

## Files Modified

### 1. `downloads-arm64.ini`
Changed from rust-lang.org nightly to Chromium's package:
```ini
[rust]
version = 11339a0ef5ed586bb7ea4f85a9b7287880caac3a-1-llvmorg-22-init-14273-gea10026b
url = https://commondatastorage.googleapis.com/chromium-browser-clang/Mac_arm64/rust-toolchain-%(version)s.tar.xz
download_filename = rust-toolchain-%(version)s.tar.xz
output_path = third_party/rust-toolchain
strip_leading_dirs = 0
```

### 2. `retrieve_and_unpack_resource.sh`
Removed manual Rust setup (symlinks, VERSION file creation) - Chromium's package is self-contained.

### 3. `patches/ungoogled-chromium/macos/fix-build-with-rust.patch`
Updated `rustc_version` to match Chromium's format:
```
rustc 1.93.0 11339a0ef5ed586bb7ea4f85a9b7287880caac3a (11339a0ef5ed586bb7ea4f85a9b7287880caac3a-1-llvmorg-22-init-14273-gea10026b chromium)
```

## Updating the Rust Toolchain

When upgrading Chromium, you may need to update the Rust toolchain:

1. **Check the expected Rust revision**:
   ```bash
   cd build/src
   grep RUST_REVISION tools/rust/update_rust.py
   ```

2. **Get the full package version**:
   ```bash
   python3 -c "import sys; sys.path.insert(0, 'tools/rust'); from update_rust import GetRustClangRevision; print(GetRustClangRevision())"
   ```

3. **Update `downloads-arm64.ini`** with the new version

4. **Verify the package exists**:
   ```bash
   curl -I "https://commondatastorage.googleapis.com/chromium-browser-clang/Mac_arm64/rust-toolchain-<version>.tar.xz"
   ```

## Verification

After downloading, verify the vendor dependencies exist:
```bash
ls build/src/third_party/rust-toolchain/lib/rustlib/src/rust/library/vendor/
```

Should show:
- `libc-0.2.177/`
- `addr2line-0.25.0/`
- `compiler_builtins/` (in parent directory)
- Many other vendored crates

## Build Impact

Using Chromium's Rust package enables:
- ✅ Building Rust standard library from source
- ✅ Rust bindgen for C++ interop
- ✅ Full Rust feature support in Chromium 144.x+
- ✅ No manual toolchain setup required

## References

- Chromium Rust Toolchain: https://chromium.googlesource.com/chromium/src/+/main/tools/rust/README.md
- Rust Package Storage: https://commondatastorage.googleapis.com/chromium-browser-clang/
- Lithium Browser: https://github.com/deiviuds/lithium-macos
