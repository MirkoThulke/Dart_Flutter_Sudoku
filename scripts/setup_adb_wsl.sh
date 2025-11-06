#!/usr/bin/env bash
set -e

# =========================================
# WSL-native ADB over TCP/IP setup for Flutter
# =========================================

# Notes:

# Replace DEVICE_IP="192.168.1.123" with your phone’s actual IP.

# Make sure your phone and WSL are on the same network.

# You only need one USB connection to enable TCP/IP debugging on the phone initially:

# On Windows or Mac
#   adb tcpip 5555



# 1️⃣ Ensure adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "❌ adb not found. Install with: sudo apt install adb"
    exit 1
fi

# 2️⃣ Kill any running adb server
echo "🔄 Stopping any running adb server..."
adb kill-server

# 3️⃣ Start adb server
echo "🔄 Starting adb server..."
adb start-server

# 4️⃣ Connect to device via TCP/IP
DEVICE_IP="192.168.1.123"  # <-- replace with your phone's IP
PORT=5555
echo "🔄 Connecting to device $DEVICE_IP:$PORT..."
adb connect "$DEVICE_IP:$PORT"

# 5️⃣ Verify connected devices
echo "🔄 Checking connected devices..."
adb devices

echo "✅ WSL is now configured to use adb over TCP/IP."

