#!/usr/bin/env bash
set -euo pipefail

REQUIRED_DOCKER_VERSION="29.0.2"
REQUIRED_API_VERSION="1.44"

echo "🔍 Checking Docker installation..."

if ! command -v docker >/dev/null 2>&1; then
  echo "❌ Docker not installed. Installing..."
else
  echo "✅ Docker binary found"
fi

# Install Docker if missing (Ubuntu / WSL)
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi

echo "🔎 Verifying Docker version..."
INSTALLED_VERSION=$(docker version --format '{{.Server.Version}}')
INSTALLED_API=$(docker version --format '{{.Server.APIVersion}}')

echo "Installed Docker version: $INSTALLED_VERSION"
echo "Installed Docker API version: $INSTALLED_API"

if [[ "$INSTALLED_VERSION" != "$REQUIRED_DOCKER_VERSION" ]]; then
  echo "❌ Docker version mismatch"
  echo "Expected: $REQUIRED_DOCKER_VERSION"
  exit 1
fi

if [[ "$INSTALLED_API" < "$REQUIRED_API_VERSION" ]]; then
  echo "❌ Docker API version too old"
  exit 1
fi

echo "✅ Docker host is compliant"