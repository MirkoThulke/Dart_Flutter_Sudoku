#!/usr/bin/env bash
set -e

# Default to release mode if not specified, but can be overridden
FLUTTER_MODE=${1:-release}
CLEAN_BUILD=false
[[ "$2" == "--clean" ]] && CLEAN_BUILD=true

echo "=============================="
echo "Building Rust + Flutter APK"
echo "Mode: $FLUTTER_MODE"
echo "=============================="

# Build Rust first
./scripts/build_rust.sh

# Build Flutter APK
./scripts/build_flutter.sh "$FLUTTER_MODE"

echo "=============================="
echo "Build complete: Rust libraries + Flutter APK"
echo "=============================="