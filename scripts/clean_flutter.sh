#!/usr/bin/env bash
set -e

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
cd "$PROJECT_ROOT"

echo "Project root is defined as: $PROJECT_ROOT"

# Set Gradle cache path depending on environment
# Use container-local cache if inside Docker
if [ -n "$DOCKER_ENV" ]; then
    export GRADLE_USER_HOME=${GRADLE_USER_HOME:-"$PROJECT_ROOT/.gradle"}
else
    # Host Gradle cache (default)
    export GRADLE_USER_HOME=${GRADLE_USER_HOME:-"$HOME/.gradle"}
fi

echo "Using GRADLE_USER_HOME: $GRADLE_USER_HOME"

echo "Performing a clean build..."
flutter clean

echo "Fetching Flutter dependencies..."
flutter pub get

# Optional: check outdated packages
# echo "Checking for outdated packages..."
# flutter pub outdated