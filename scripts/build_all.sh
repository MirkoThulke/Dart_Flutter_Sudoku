#!/usr/bin/env bash
set -e

##############################################################################
# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.
#
# Dockerfile for Flutter + Rust + Android + Web integration testing
# Fully self-contained environment for desktop, web, and mobile builds.
#
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