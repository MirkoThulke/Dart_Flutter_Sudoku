#!/usr/bin/env bash
set -e

echo "🧹 Cleaning Flutter & Gradle caches..."

# ------------------------------------------------------------
# Detect script and project root
# ------------------------------------------------------------
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
cd "$PROJECT_ROOT"

# ------------------------------------------------------------
# Detect Docker environment
# ------------------------------------------------------------
IS_DOCKER=false
if [ -f "/.dockerenv" ] || grep -q docker /proc/1/cgroup 2>/dev/null; then
    IS_DOCKER=true
    echo "🐳 Running inside Docker"
else
    echo "🐧 Running on Host (WSL2 or Linux)"
fi

# ------------------------------------------------------------
# Determine HOME directory safely
# ------------------------------------------------------------
if [ "$IS_DOCKER" = true ]; then
    HOME="${HOME:-/home/flutteruser}"
else
    # WSL2 HOST usually has a valid HOME already
    HOME="${HOME}"
fi

echo "🏠 HOME directory: $HOME"

# ------------------------------------------------------------
# Stop Gradle daemons
# ------------------------------------------------------------
if [ -f "android/gradlew" ]; then
  echo "🛑 Stopping Gradle daemons..."
  bash android/gradlew --stop || true
else
  echo "⚠️ gradlew not found, skipping daemon stop."
fi

# ------------------------------------------------------------
# Clean GLOBAL Gradle cache
# ------------------------------------------------------------
GRADLE_CACHE="$HOME/.gradle/caches"
echo "🗑 Removing Gradle cache at $GRADLE_CACHE"

rm -rf "$GRADLE_CACHE/transforms-*" \
       "$GRADLE_CACHE/modules-2" \
       "$GRADLE_CACHE/jars-9" \
       "$GRADLE_CACHE/daemon" || true

# ------------------------------------------------------------
# Clean PROJECT build folders
# ------------------------------------------------------------
echo "🗑 Removing project build directories..."

rm -rf "$PROJECT_ROOT/.gradle" \
       "$PROJECT_ROOT/build" \
       "$PROJECT_ROOT/android/build" \
       "$PROJECT_ROOT/android/.gradle" || true

# ------------------------------------------------------------
# Remove Flutter bin cache (very important for plugin errors)
# ------------------------------------------------------------
# Try to determine FLUTTER_HOME if not set
if [ -z "$FLUTTER_HOME" ]; then
    # Try common locations
    if [ -d "$HOME/sdks/flutter" ]; then
        FLUTTER_HOME="$HOME/sdks/flutter"
    elif command -v flutter &> /dev/null; then
        FLUTTER_HOME="$(dirname "$(dirname "$(command -v flutter)")")"
    fi
fi

if [ -n "$FLUTTER_HOME" ]; then
    echo "🗑 Removing Flutter cache at $FLUTTER_HOME/bin/cache"
    rm -rf "$FLUTTER_HOME/bin/cache" || true
else
    echo "⚠️ Could not detect FLUTTER_HOME, skipping Flutter cache clean."
fi

# ------------------------------------------------------------
# Clean Dart pub cache (safe in WSL & Docker)
# ------------------------------------------------------------
echo "🗑 Cleaning Dart pub cache..."
rm -rf "$HOME/.pub-cache" || true

# ------------------------------------------------------------
# Flutter clean & dependency restore
# ------------------------------------------------------------
if ! command -v flutter &> /dev/null; then
    echo "❌ flutter command not found!"
    exit 1
fi

echo "🧽 Running flutter clean..."
flutter clean

echo "📦 Fetching dependencies..."
flutter pub get --no-precompile

echo "✅ Flutter & Gradle caches fully reset."
