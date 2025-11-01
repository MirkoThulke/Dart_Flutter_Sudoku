#!/usr/bin/env bash
set -e

# Usage:
#   ./tasks/build.sh [mode] [--clean]
# Example:
#   ./tasks/build.sh release --clean
#   ./tasks/build.sh debug
#   ./tasks/build.sh profile

FLUTTER_MODE=${1:-release}
CLEAN_BUILD=false

if [[ "$2" == "--clean" ]]; then
  CLEAN_BUILD=true
fi

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

cd "$PROJECT_ROOT"

echo "Fetching Flutter dependencies..."
flutter pub get

if [ "$CLEAN_BUILD" = true ]; then
  echo "Performing a clean build..."
  flutter clean
fi

echo "Building Flutter APK in $FLUTTER_MODE mode..."
flutter build apk --$FLUTTER_MODE

APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLUTTER_MODE.apk"
echo "✅ Flutter build finished. APK located at: $APK_PATH"
