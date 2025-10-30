#!/usr/bin/env bash
set -e

# Default to release mode if not specified
FLUTTER_MODE=${1:-release}

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."

cd "$PROJECT_ROOT"

echo "Fetching Flutter dependencies..."
flutter pub get

echo "Building Flutter APK in $FLUTTER_MODE mode..."
flutter build apk --$FLUTTER_MODE

APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLUTTER_MODE.apk"
echo "Flutter build finished. APK located at $APK_PATH"
