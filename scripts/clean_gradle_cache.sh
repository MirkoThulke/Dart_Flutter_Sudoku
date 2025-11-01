#!/usr/bin/env bash
# ====================================================================
# clean_flutter.sh
# Fully reset Flutter + Gradle + Kotlin build caches (local & global)
# ====================================================================

set -e  # Stop on first error
echo "🧹 Cleaning Flutter & Gradle caches..."

# Detect project root (this script should live in ./scripts/)
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

cd "$PROJECT_ROOT" || exit 1

# 1️⃣ Stop all Gradle daemons
if [ -f "android/gradlew" ]; then
  echo "Stopping Gradle daemons..."
  bash android/gradlew --stop || true
else
  echo "⚠️ gradlew not found, skipping daemon stop."
fi

# 2️⃣ Remove Gradle caches
echo "Removing global Gradle caches..."
GRADLE_HOME="$HOME/.gradle/caches"

if [ -d "$GRADLE_HOME" ]; then
  rm -rf "$GRADLE_HOME/transforms-4" \
         "$GRADLE_HOME/modules-2" \
         "$GRADLE_HOME/jars-9" \
         "$GRADLE_HOME/daemon" || true
else
  echo "⚠️ No global Gradle caches found at $GRADLE_HOME"
fi

# 3️⃣ Remove local build folders
echo "Removing local project build folders..."
rm -rf "$PROJECT_ROOT/.gradle" \
       "$PROJECT_ROOT/build" \
       "$PROJECT_ROOT/android/build" || true

# 4️⃣ Flutter clean + dependencies
echo "Running flutter clean..."
flutter clean

echo "Fetching Flutter dependencies..."
flutter pub get

echo "✅ Flutter & Gradle caches fully reset."
