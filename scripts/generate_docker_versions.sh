#!/usr/bin/env bash
set -e

# ------------------------------------------------------------
# Resolve project root
# ------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"
echo "Project root: $PROJECT_ROOT"

# ------------------------------------------------------------
# Detect Flutter version and channel
# ------------------------------------------------------------
if command -v flutter >/dev/null 2>&1; then
    FLUTTER_VERSION=$(flutter --version --machine | grep '"frameworkVersion":' | cut -d'"' -f4)
    FLUTTER_CHANNEL=$(flutter channel | grep '*' | awk '{print $2}')
    FLUTTER_DART_VERSION=$(flutter --version --machine | grep '"dartVersion":' | cut -d'"' -f4)
else
    echo "Flutter not found in PATH"
    FLUTTER_VERSION=null
    FLUTTER_CHANNEL=stable
    FLUTTER_DART_VERSION=null
fi

# ------------------------------------------------------------
# Detect Android SDK and NDK versions
# ------------------------------------------------------------
ANDROID_SDK_ROOT=${ANDROID_SDK_ROOT:-"$HOME/Android/Sdk"}
ANDROID_SDK_TOOLS_VERSION=null
ANDROID_NDK_VERSION=null

if [ -d "$ANDROID_SDK_ROOT/cmdline-tools/latest/bin" ]; then
    ANDROID_SDK_TOOLS_VERSION=$("$ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager" --version 2>/dev/null || echo "null")
fi

# Try to detect installed NDK
if [ -d "$ANDROID_SDK_ROOT/ndk" ]; then
    # Pick the latest directory (lexical sort works for NDK versions)
    LATEST_NDK_DIR=$(ls -1 "$ANDROID_SDK_ROOT/ndk" | sort -V | tail -1)
    ANDROID_NDK_VERSION=$LATEST_NDK_DIR
fi

# ------------------------------------------------------------
# Detect Gradle version
# ------------------------------------------------------------
if command -v gradle >/dev/null 2>&1; then
    GRADLE_VERSION=$(gradle -v | grep Gradle | awk '{print $2}')
else
    GRADLE_VERSION=null
fi

# ------------------------------------------------------------
# Detect CMake version
# ------------------------------------------------------------
if command -v cmake >/dev/null 2>&1; then
    cmake_candidates=$($sdkmanager --list | grep -oP 'cmake;\K[0-9.]+')
    CMAKE_VERSION=$(echo "$cmake_candidates" | sort -V | tail -n 1)
else
    CMAKE_VERSION=null
fi


# ------------------------------------------------------------
# Detect Rust version
# ------------------------------------------------------------
if command -v rustc >/dev/null 2>&1; then
    RUST_VERSION=$(rustc --version | awk '{print $2}')
else
    RUST_VERSION=null
fi



# ------------------------------------------------------------
# Output Dockerfile ENV lines
# ------------------------------------------------------------
echo "# ------------------------------------------------------------"
echo "# Dockerfile version lock variables (copy to Dockerfile)"
echo "# ------------------------------------------------------------"
echo "ENV FLUTTER_VERSION=$FLUTTER_VERSION"
echo "ENV FLUTTER_CHANNEL=$FLUTTER_CHANNEL"
echo "ENV FLUTTER_DART_VERSION=$FLUTTER_DART_VERSION"
echo "ENV ANDROID_SDK_ROOT=$ANDROID_SDK_ROOT"
echo "ENV ANDROID_SDK_TOOLS_VERSION=$ANDROID_SDK_TOOLS_VERSION"
echo "ENV ANDROID_NDK_VERSION=$ANDROID_NDK_VERSION"
echo "ENV GRADLE_VERSION=$GRADLE_VERSION"
echo "ENV CMAKE_VERSION=$CMAKE_VERSION"
echo "ENV RUST_VERSION=$RUST_VERSION"

FLUTTER_VERSION=$(flutter --version --machine | jq -r '.frameworkVersion')
FLUTTER_DART_VERSION=$(flutter --version --machine | jq -r '.dartSdkVersion')
GRADLE_VERSION=$(./android/gradlew --version | grep Gradle | awk '{print $2}')

echo "ENV FLUTTER_VERSION=$FLUTTER_VERSION"
echo "ENV FLUTTER_DART_VERSION=$FLUTTER_DART_VERSION"
echo "ENV GRADLE_VERSION=$GRADLE_VERSION"