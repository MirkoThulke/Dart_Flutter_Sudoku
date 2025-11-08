#!/usr/bin/env bash
set -e

# =========================================
# Fully automatic WSL-native ADB over TCP/IP setup
# =========================================

# ✅ How it works

# First run:
# Detects USB device.
# Switches to TCP/IP mode.
# Automatically detects IP and saves it.

# Future runs:
# Reads stored IP and connects automatically.
# No USB connection required anymore.

DEVICE_IP_FILE="$HOME/.adb_device_ip"
PORT=5555

# 1️⃣ Ensure adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "❌ adb not found. Install with: sudo apt install adb"
    exit 1
fi

# 2️⃣ Kill any running adb server
echo "🔄 Stopping any running adb server..."
adb kill-server || true

# 3️⃣ Start adb server
echo "🔄 Starting adb server..."
adb start-server || true

# 4️⃣ Detect USB-connected device
USB_DEVICE=$(adb devices | grep -v "List of devices" | grep -v "offline" | grep -v "unauthorized" | awk '{print $1}' | head -n 1 || true)

if [ -n "$USB_DEVICE" ]; then
    echo "📱 USB device detected: $USB_DEVICE"
    
    # Only enable TCP/IP mode if first time or IP file doesn't exist
    if [ ! -f "$DEVICE_IP_FILE" ]; then
        echo "🔄 Switching device to TCP/IP mode on port $PORT..."
        adb -s "$USB_DEVICE" tcpip $PORT || echo "⚠️ Failed to switch device to TCP/IP mode"
    fi
else
    echo "⚠️ No USB device detected. TCP/IP mode must have been enabled previously."
fi

# 5️⃣ Detect device IP
if [ -f "$DEVICE_IP_FILE" ]; then
    DEVICE_IP=$(cat "$DEVICE_IP_FILE")
    echo "📌 Using saved device IP: $DEVICE_IP"
else
    DEVICE_IP=$(adb shell ip -f inet addr show wlan0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -n 1 || true)
    
    if [ -z "$DEVICE_IP" ]; then
        read -p "Enter your phone IP for TCP/IP connection: " DEVICE_IP
    fi
    
    echo "$DEVICE_IP" > "$DEVICE_IP_FILE"
    echo "✅ Saved device IP for future sessions: $DEVICE_IP"
fi

# 6️⃣ Connect to device via TCP/IP
echo "🔄 Connecting to device $DEVICE_IP:$PORT..."
adb connect "$DEVICE_IP:$PORT" || echo "⚠️ Could not connect to device $DEVICE_IP:$PORT"

# 7️⃣ List all devices
echo "🔄 Listing all devices..."
adb devices -l || true

echo "✅ WSL is now configured to use adb over TCP/IP."
