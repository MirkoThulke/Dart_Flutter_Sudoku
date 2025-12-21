#!/usr/bin/env bash
set -e  # Exit on any error


# ------------------------------------------------------------
# build_rust.sh
# Compile Rust backend for Android (all targets) and place
# shared libraries into Flutter jniLibs folder
# ------------------------------------------------------------


# Resolve script directory
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RUST_LIB_DIR="$SCRIPT_DIR/../rust/rust_lib"
JNI_LIBS_PATH="$SCRIPT_DIR/../android/app/src/main/jniLibs"

cd "$RUST_LIB_DIR"

echo "Cleaning previous Rust build..."
cargo clean

echo "Building Rust backend for Android targets..."
cargo ndk \
    -t armeabi-v7a \
    -t arm64-v8a \
    -t x86 \
    -t x86_64 \
    -o "$JNI_LIBS_PATH" \
    build --release

echo "Rust build finished. Shared libraries placed in $JNI_LIBS_PATH"
echo "Resulting files:"
ls -R "$JNI_LIBS_PATH"