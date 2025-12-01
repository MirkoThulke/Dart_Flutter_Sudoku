#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$PROJECT_DIR/android"
LOCAL_PROPERTIES="$ANDROID_DIR/local.properties"

# Centralized version settings (keep in sync with versions.gradle)
NDK_MAIN_VERSION="28.0.13004108"
NDK_LEGACY_VERSION="26.1.10909125"
CMAKE_VERSION="3.22.1"

echo "🔧 Generating android/local.properties..."

rm -f "$LOCAL_PROPERTIES"

##############################################
# Detect Docker
##############################################
IS_DOCKER=false
if [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
  IS_DOCKER=true
fi

##############################################
# Detect WSL
##############################################
IS_WSL=false
if grep -qi "microsoft" /proc/version; then
  IS_WSL=true
fi

##############################################
# Select SDK location
##############################################
if $IS_DOCKER; then
    echo "🐋 Running inside Docker → using /opt/android/sdk"
    SDK_DIR="/opt/android/sdk"

elif $IS_WSL; then
    echo "🐧 Running in WSL → using Linux Android SDK"
    SDK_DIR="$HOME/Android/Sdk"

else
    echo "🐧 Native Linux environment"
    SDK_DIR="$HOME/Android/Sdk"
fi

##############################################
# Validate SDK
##############################################
if [ ! -d "$SDK_DIR" ]; then
    echo "❌ ERROR: Android SDK not found at $SDK_DIR"
    exit 1
fi

if [ ! -d "$SDK_DIR/ndk" ]; then
    echo "❌ ERROR: No NDK folder found in $SDK_DIR/ndk"
    exit 1
fi

##############################################
# Use explicit main NDK version
##############################################
MAIN_NDK_DIR="$SDK_DIR/ndk/$NDK_MAIN_VERSION"

if [ ! -d "$MAIN_NDK_DIR/toolchains/llvm" ]; then
    echo "❌ ERROR: Main NDK not found or invalid:"
    echo "   $MAIN_NDK_DIR"
    exit 1
fi

echo "✅ Using MAIN NDK: $MAIN_NDK_DIR"

##############################################
# Detect cmake folder if available
##############################################
CMAKE_DIR="$SDK_DIR/cmake/$CMAKE_VERSION"

if [ -d "$CMAKE_DIR/bin" ]; then
    echo "🔧 Using CMake: $CMAKE_DIR"
    WRITE_CMAKE="cmake.dir=$CMAKE_DIR"
else
    echo "⚠️ No CMake inside SDK, skipping cmake.dir"
    WRITE_CMAKE=""
fi

##############################################
# Write local.properties
##############################################
{
echo "sdk.dir=$SDK_DIR"
echo "ndk.dir=$MAIN_NDK_DIR"
[ -n "$WRITE_CMAKE" ] && echo "$WRITE_CMAKE"
} > "$LOCAL_PROPERTIES"

echo "✅ Generated android/local.properties:"
cat "$LOCAL_PROPERTIES"
