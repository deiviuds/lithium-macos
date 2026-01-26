#!/usr/bin/env bash

# Script to retrieve and unpack resources to build Chromium macOS

set -eux

_root_dir="$(dirname "$(greadlink -f "$0")")"
_download_cache="$_root_dir/build/download_cache"
_src_dir="$_root_dir/build/src"
_main_repo="$_root_dir/helium-chromium"

# Clone to get the Chromium Source
clone=true
retrieve_generic=false
retrieve_arch_specific=false

while getopts 'dgp' OPTION; do
  case "$OPTION" in
    d)
        clone=false
        ;;
    g)
        retrieve_generic=true
        ;;
    p)
        retrieve_arch_specific=true
        ;;
    ?)
        echo "Usage: $0 [-d] [-g] [-p]"
        echo "  -d: Use download instead of git clone to get Chromium Source"
        echo "  -g: Retrieve and unpack Chromium Source and general resources"
        echo "  -p: Retrieve and unpack platform-specific resources"
        exit 1
        ;;
    esac
done

shift "$(($OPTIND -1))"

_target_cpu=${1:-arm64}

if $retrieve_generic; then
    if $clone; then
        if [[ $_target_cpu == "arm64" ]]; then
            # For arm64 (Apple Silicon)
            python3 "$_main_repo/utils/clone.py" -p mac-arm -o "$_src_dir"
        else
            # For amd64 (Intel)
            python3 "$_main_repo/utils/clone.py" -p mac -o "$_src_dir"
        fi
    else
        python3 "$_main_repo/utils/downloads.py" retrieve -i "$_main_repo/downloads.ini" -c "$_download_cache"
        python3 "$_main_repo/utils/downloads.py" unpack -i "$_main_repo/downloads.ini" -c "$_download_cache" "$_src_dir"
    fi

    # Retrieve and unpack general resources
    python3 "$_main_repo/utils/downloads.py" retrieve -i "$_root_dir/downloads.ini" -c "$_download_cache"
    python3 "$_main_repo/utils/downloads.py" retrieve -i "$_main_repo/deps.ini" -c "$_download_cache"
    python3 "$_main_repo/utils/downloads.py" unpack -i "$_root_dir/downloads.ini" -c "$_download_cache" "$_src_dir"
    python3 "$_main_repo/utils/downloads.py" unpack -i "$_main_repo/deps.ini" -c "$_download_cache" "$_src_dir"
fi

if $retrieve_arch_specific; then
    rm -rf "$_src_dir/third_party/llvm-build/Release+Asserts/"
    rm -rf "$_src_dir/third_party/rust-toolchain/"
    rm -rf "$_src_dir/third_party/node/mac/"
    rm -rf "$_src_dir/third_party/node/mac_arm64/"
    mkdir -p "$_src_dir/third_party/llvm-build/Release+Asserts"

    # Retrieve and unpack platform-specific resources
    if [[ $(uname -m) == "arm64" ]]; then
        python3 "$_main_repo/utils/downloads.py" retrieve -i "$_root_dir/downloads-arm64.ini" -c "$_download_cache"
        mkdir -p "$_src_dir/third_party/node/mac_arm64/node-darwin-arm64/"
        python3 "$_main_repo/utils/downloads.py" unpack -i "$_root_dir/downloads-arm64.ini" -c "$_download_cache" "$_src_dir"
        if [[ $_target_cpu == "x86_64" ]]; then
            python3 "$_main_repo/utils/downloads.py" retrieve -i "$_root_dir/downloads-x86-64-rustlib.ini" -c "$_download_cache"
            python3 "$_main_repo/utils/downloads.py" unpack -i "$_root_dir/downloads-x86-64-rustlib.ini" -c "$_download_cache" "$_src_dir"
        fi
    else
        python3 "$_main_repo/utils/downloads.py" retrieve -i "$_root_dir/downloads-x86-64.ini" -c "$_download_cache"
        mkdir -p "$_src_dir/third_party/node/mac/node-darwin-x64/"
        python3 "$_main_repo/utils/downloads.py" unpack -i "$_root_dir/downloads-x86-64.ini" -c "$_download_cache" "$_src_dir"
        if [[ $_target_cpu == "arm64" ]]; then
            python3 "$_main_repo/utils/downloads.py" retrieve -i "$_root_dir/downloads-arm64-rustlib.ini" -c "$_download_cache"
            python3 "$_main_repo/utils/downloads.py" unpack -i "$_root_dir/downloads-arm64-rustlib.ini" -c "$_download_cache" "$_src_dir"
        fi
    fi

    ## Rust Resource Cleanup
    # Remove any stray VERSION file from third_party/ that may interfere with C++20 <version> header
    # On macOS's case-insensitive filesystem, third_party/VERSION is found as third_party/version
    # which breaks compilation when C++ includes <version>
    rm -f "$_src_dir/third_party/VERSION" "$_src_dir/third_party/version" 2>/dev/null || true

    # Lithium: Chromium's prebuilt Rust toolchain is self-contained and doesn't need manual setup
    # The package from commondatastorage.googleapis.com includes:
    # - bin/rustc, cargo, rustfmt, bindgen (already in correct locations)
    # - lib/rustlib/src/rust/library/vendor/ (with all dependencies for stdlib builds)
    # - VERSION file (in Chromium's expected format)
    # No symlinks or version file creation needed.

    _llvm_dir="$_src_dir/third_party/llvm-build/Release+Asserts"
    _llvm_bin_dir="$_llvm_dir/bin"

    ln -s "$_llvm_bin_dir/llvm-install-name-tool" "$_llvm_bin_dir/install_name_tool"
fi
