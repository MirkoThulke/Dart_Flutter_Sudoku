##############################################################################

# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.

# Date: 2025, VERSAILLES, FRANCE

# License: "All Rights Reserved – View Only"

# Permission is hereby granted to view and share this code in its original,
# unmodified form for educational or reference purposes only.

# Any other use, including but not limited to copying, modification,
# redistribution, commercial use, or inclusion in other projects, is strictly
# prohibited without the express written permission of the author.

# The Software is provided "AS IS", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose, and noninfringement. In no event shall the
# author be liable for any claim, damages, or other liability arising from the
# use of the Software.

# Contact: MIRKO THULKE (for permission requests)

##############################################################################

#!/bin/bash
# ------------------------------------------------------------
# build_rust.sh
# Compile Rust backend for Android (all targets) and place
# shared libraries into Flutter jniLibs folder
# ------------------------------------------------------------

set -e  # Exit on any error

# Go to the Rust library folder
cd "$(dirname "$0")/rust/rust_lib"

# Output path for jniLibs (relative to Rust folder)
JNI_LIBS_PATH="../../android/app/src/main/jniLibs"

echo "Cleaning previous build..."
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

# Optional: show resulting files
echo "Resulting files:"
ls -R "$JNI_LIBS_PATH"
