#!/usr/bin/env bash
set -e

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
ANDROID_DIR="$PROJECT_DIR/android"
LOCAL_PROPERTIES="$ANDROID_DIR/local.properties"

# Centralized versions (keep in sync with versions.gradle)
NDK_MAIN="28.2.13676358"      # Used in Docker & native Linux
NDK_LEGACY="26.1.10909125"    # Used in WSL2
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
# Detect WSL2
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
    echo "🐧 Running in WSL2 → using Linux Android SDK"
    SDK_DIR="$HOME/Android/Sdk"

else
    echo "🐧 Native Linux environment → using $HOME/Android/Sdk"
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
# Select NDK based on environment
##############################################
if $IS_DOCKER; then
    NDK_VERSION="$NDK_MAIN"
elif $IS_WSL; then
    NDK_VERSION="$NDK_LEGACY"
else
    NDK_VERSION="$NDK_MAIN"
fi

NDK_DIR="$SDK_DIR/ndk/$NDK_VERSION"

if [ ! -d "$NDK_DIR/toolchains/llvm" ]; then
    echo "❌ ERROR: NDK not found or invalid:"
    echo "   $NDK_DIR"
    exit 1
fi

echo "✅ Using NDK: $NDK_DIR"

##############################################
# Detect CMake folder
##############################################
CMAKE_DIR="$SDK_DIR/cmake/$CMAKE_VERSION"

if [ -d "$CMAKE_DIR/bin" ]; then
    echo "🔧 Using CMake: $CMAKE_DIR"
    WRITE_CMAKE="cmake.dir=$CMAKE_DIR"
else
    echo "⚠️ CMake $CMAKE_VERSION not found inside SDK, skipping cmake.dir"
    WRITE_CMAKE=""
fi

##############################################
# Write local.properties
##############################################
{
echo "sdk.dir=$SDK_DIR"
echo "ndk.dir=$NDK_DIR"
[ -n "$WRITE_CMAKE" ] && echo "$WRITE_CMAKE"
} > "$LOCAL_PROPERTIES"

echo "✅ Generated android/local.properties:"
cat "$LOCAL_PROPERTIES"