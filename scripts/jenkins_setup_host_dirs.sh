#!/usr/bin/env bash
set -euo pipefail

echo "UID is: $JENKINS_UID"
echo "GID is: $JENKINS_GID"

echo "HOST_WORKSPACE is: ${HOST_WORKSPACE}"
echo "HOST_CACHE is: ${HOST_CACHE}"

echo "📁 Creating host mount directories"
mkdir -p "${HOST_WORKSPACE}"
mkdir -p "${HOST_CACHE}"

echo "🔧 Setting ownership and permissions"
chown -R ${JENKINS_UID}:${JENKINS_GID} "${HOST_WORKSPACE}" "${HOST_CACHE}"
chmod -R 770 "${HOST_WORKSPACE}" "${HOST_CACHE}"

echo "✅ Host directories ready"