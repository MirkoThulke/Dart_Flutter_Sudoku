#!/usr/bin/env bash
set -e

# =========================================
# Cross-platform Flutter build script
# =========================================

# Parse arguments
FLUTTER_MODE=${1:-release}
CLEAN_BUILD=false
if [[ "$2" == "--clean" ]]; then
  CLEAN_BUILD=true
fi

# Detect environment
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    ENV_TYPE="WSL"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ENV_TYPE="WINDOWS"
else
    ENV_TYPE="LINUX"
fi
echo "Detected environment: $ENV_TYPE"

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$ENV_TYPE" == "WINDOWS" ]]; then
    if [[ "$SCRIPT_DIR" == //wsl$* || "$SCRIPT_DIR" == \\\\wsl$* ]]; then
        echo "❌ ERROR: UNC path detected. Copy project to a Windows path."
        exit 1
    fi
    PROJECT_ROOT="$SCRIPT_DIR/.."
else
    PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
fi

cd "$PROJECT_ROOT" || { echo "❌ Failed to cd to project root: $PROJECT_ROOT"; exit 1; }
echo "📂 Current directory: $(pwd)"

# Verify Flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter not found in PATH"
  exit 1
fi

# Fetch dependencies
echo "📦 Fetching Flutter dependencies..."
flutter pub get

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
  echo "🧹 Performing a clean build..."
  flutter clean
fi

# Build APK
echo "🏗️ Building Flutter APK in $FLUTTER_MODE mode..."
flutter build apk --$FLUTTER_MODE

# Print APK path
APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLUTTER_MODE.apk"
if [ -f "$APK_PATH" ]; then
  echo "✅ Flutter build finished!"
  echo "📦 APK located at: $APK_PATH"
else
  echo "❌ APK not found at expected location: $APK_PATH"
  exit 1
fi

