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

# ------------------------------------------------------------
# Resolve project root
# ------------------------------------------------------------

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"
echo "Project root is defined as: $PROJECT_ROOT"

# ------------------------------------------------------------
# Set Gradle cache path depending on environment
# ------------------------------------------------------------

if [ -n "$DOCKER_ENV" ]; then
export GRADLE_USER_HOME=${GRADLE_USER_HOME:-"$PROJECT_ROOT/.gradle"}
else
export GRADLE_USER_HOME=${GRADLE_USER_HOME:-"$HOME/.gradle"}
fi
echo "Using GRADLE_USER_HOME: $GRADLE_USER_HOME"

# ------------------------------------------------------------
# Update android/local.properties
# ------------------------------------------------------------

echo "🔧 Regenerating local.properties..."
chmod +x ./scripts/generate_local_properties.sh
./scripts/generate_local_properties.sh

# ------------------------------------------------------------
# Ensure integration_test is in dev_dependencies
# ------------------------------------------------------------

PUBSPEC_FILE="$PROJECT_ROOT/pubspec.yaml"

if ! grep -q "integration_test:" "$PUBSPEC_FILE"; then
echo "Adding integration_test to dev_dependencies in pubspec.yaml"
# Insert under dev_dependencies section if exists
if grep -q "dev_dependencies:" "$PUBSPEC_FILE"; then
awk '/dev_dependencies:/ {print; print "  integration_test: ^1.0.2"; next}1' "$PUBSPEC_FILE" > "$PUBSPEC_FILE.tmp" && mv "$PUBSPEC_FILE.tmp" "$PUBSPEC_FILE"
else
# Append at end if no dev_dependencies section
echo -e "\ndev_dependencies:\n  integration_test: ^1.0.2" >> "$PUBSPEC_FILE"
fi
else
echo "integration_test already present in pubspec.yaml"
fi

# ------------------------------------------------------------
# Clean and fetch dependencies
# ------------------------------------------------------------

echo "Performing a clean build..."
flutter clean

echo "Fetching Flutter dependencies..."
flutter pub get

echo "✅ Clean and setup complete!"