#!/usr/bin/env bash
set -euo pipefail

##############################################################################
# Author: MIRKO THULKE
# Copyright (c) 2025, MIRKO THULKE
# All rights reserved.
#
# Dockerfile for Flutter + Rust + Android + Web integration testing
# Fully self-contained environment for desktop, web, and mobile builds.
#
# License: "All Rights Reserved – View Only"

# Permission is hereby granted to view and share this code in its original,
# unmodified form for educational or reference purposes only.

# Any other use, including but not limited to copying, modification,
# redistribution, commercial use, or inclusion in other projects, is strictly
# prohibited without the express written permission of the author.

# The Software is provided "AS IS", without warranty of any kind, express or
# implied, including but not limited to the warranties of merchantability,
# fitness for a particular purpose, and noninfringement. In no event shall the
# author be liable for any claim, damages, or other liability arising from the
# use of the Software.

# Contact: MIRKO THULKE (for permission requests)
##############################################################################

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