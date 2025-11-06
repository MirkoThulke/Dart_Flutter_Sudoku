#!/usr/bin/env bash
set -e

# =========================================
# Fully automated WSL-native ADB over TCP/IP setup for Flutter
# =========================================

# Notes:
# - Requires adb installed in WSL: sudo apt install adb
# - Phone must have "USB Debugging" enabled
# - Only one USB connection is needed to enable TCP/IP debugging
# - Phone and WSL must be on the same Wi-Fi network

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

# 4️⃣ Detect phone IP automatically (requires USB connection)
DEVICE_IP=$(adb shell ip -f inet addr show wlan0 | grep -oP 'inet \K[\d.]+')

if [ -z "$DEVICE_IP" ]; then
    echo "❌ Could not detect phone IP. Make sure USB debugging is enabled and phone is connected via USB."
    exit 1
fi
echo "✅ Detected phone IP: $DEVICE_IP"

# 5️⃣ Switch phone to TCP/IP mode (only required once)
echo "🔄 Switching device to TCP/IP mode on port 5555..."
adb tcpip 5555

# 6️⃣ Connect via TCP/IP
PORT=5555
echo "🔄 Connecting to device $DEVICE_IP:$PORT..."
adb connect "$DEVICE_IP:$PORT"

# 7️⃣ Verify connected devices
echo "🔄 Checking connected devices..."
adb devices -l

echo "✅ WSL is now configured to use adb over TCP/IP."