#!/usr/bin/env bash
set -euo pipefail

# --------------------
# Run with sudo ./jenkins_setup_host_dirs.sh
# --------------------

JENKINS_UID=2000
JENKINS_GID=2000

HOST_HOME="/home/mirko/jenkins_host_workspace"
HOST_CACHE="/home/mirko/jenkins_host_cache"


echo "HOST_HOME is: ${HOST_HOME}"
echo "HOST_CACHE is: ${HOST_CACHE}"

# -------------------------
# Terminal prompt fallback
# -------------------------
read -p "Do you want to delete existing host directories? [y/N]: " choice
# Default is "No" if user just presses ENTER
if [[ "${choice,,}" == "y" ]]; then   # convert to lowercase for safety
    echo "🗑 Deleting host directories..."
    sudo rm -rf /home/mirko/jenkins_host_*
else
    echo "Skipping deletion."
fi



# -------------------------
# Create directories
# -------------------------
echo "📁 Creating host mount directories"
mkdir -p "${HOST_HOME}" "${HOST_CACHE}"

# Set ownership and permissions safely
sudo chown -R ${JENKINS_UID}:${JENKINS_GID} "${HOST_HOME}" "${HOST_CACHE}" || true
chmod -R 770 "${HOST_HOME}" "${HOST_CACHE}" 2>/dev/null || true

echo "✅ Host directories ready"