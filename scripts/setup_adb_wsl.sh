#!/usr/bin/env bash
set -e

# =========================================
# WSL-native ADB over TCP/IP setup for Flutter
# =========================================

DEVICE_IP_FILE="$HOME/.adb_device_ip"
PORT=5555

# 1️⃣ Detect Windows host IP from WSL
echo "ℹ️ Detecting Windows host IP from WSL..."
WIN_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
if [ -z "$WIN_IP" ]; then
    echo "❌ Could not detect Windows host IP."
    exit 1
fi
echo "ℹ️ Detected Windows host IP: $WIN_IP"

# 2️⃣ Set ADB_SERVER_SOCKET for this session
export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037
echo "✅ Set ADB_SERVER_SOCKET for this session: $ADB_SERVER_SOCKET"

# Persist for future sessions
if ! grep -q "ADB_SERVER_SOCKET" ~/.bashrc; then
    echo "export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037" >> ~/.bashrc
    echo "✅ Added ADB_SERVER_SOCKET to ~/.bashrc for future sessions"
fi

# 3️⃣ Ensure adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "❌ adb not found. Install with: sudo apt install adb"
    exit 1
fi

# 4️⃣ Check connectivity to Windows ADB
echo "ℹ️ Checking connectivity to Windows ADB..."
if ! nc -z -w 3 "$WIN_IP" 5037 >/dev/null 2>&1; then
    echo "⚠️ Cannot connect to Windows host ADB at $WIN_IP:5037."
    echo "💡 Ensure Windows firewall allows inbound TCP connections on port 5037 from WSL."
    echo "💡 You may need to temporarily disable firewall or create an inbound rule:"
    echo "   - Open Windows Firewall settings"
    echo "   - Allow inbound TCP traffic on port 5037 for adb.exe"
    read -p "Press Enter to continue anyway or Ctrl+C to abort..."
fi

# 5️⃣ Stop any running adb server
echo "🔄 Stopping any running adb server in WSL..."
adb kill-server || true

# 6️⃣ Start adb server
echo "🔄 Starting adb server in WSL..."
adb start-server || true

# 7️⃣ Detect USB-connected device for first-time TCP/IP setup
USB_DEVICE=$(adb devices | grep -v "List of devices" | grep -v "offline" | grep -v "unauthorized" | awk '{print $1}' | head -n 1 || true)

if [ -n "$USB_DEVICE" ]; then
    echo "📱 USB device detected: $USB_DEVICE"

    if [ ! -f "$DEVICE_IP_FILE" ]; then
        echo "🔄 Switching device to TCP/IP mode on port $PORT..."
        adb -s "$USB_DEVICE" tcpip $PORT || echo "⚠️ Failed to switch device to TCP/IP mode"
        echo "✅ TCP/IP mode enabled. You can now unplug the USB cable."
    fi
else
    echo "⚠️ No USB device detected. TCP/IP mode must have been enabled previously."
fi

# 8️⃣ Detect device IP
if [ -f "$DEVICE_IP_FILE" ]; then
    DEVICE_IP=$(cat "$DEVICE_IP_FILE")
    echo "📌 Using saved device IP: $DEVICE_IP"
else
    echo "ℹ️ Attempting to detect device IP from USB/TCP..."
    DEVICE_IP=$(adb shell ip -f inet addr show wlan0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -n 1 || true)

    if [ -z "$DEVICE_IP" ]; then
        read -p "Enter your phone IP for TCP/IP connection: " DEVICE_IP
    fi

    echo "$DEVICE_IP" > "$DEVICE_IP_FILE"
    echo "✅ Saved device IP for future sessions: $DEVICE_IP"
fi

# 9️⃣ Optional firewall check for device
echo "🔍 Checking connectivity to device $DEVICE_IP:$PORT..."
if ! ping -c 1 "$DEVICE_IP" &>/dev/null; then
    echo "⚠️ Cannot reach $DEVICE_IP. Check your firewall and Wi-Fi network."
    echo "💡 Make sure WSL can reach the phone on the same network and port $PORT is open."
fi

# 🔟 Connect to device via TCP/IP
echo "🔄 Connecting to device $DEVICE_IP:$PORT..."
adb connect "$DEVICE_IP:$PORT" || echo "⚠️ Could not connect to device $DEVICE_IP:$PORT"

# 1️⃣1️⃣ List all devices
echo "🔄 Listing all devices..."
adb devices -l || true

# 📝 User instructions
echo
echo "💡 Instructions:"
echo " - If this was the first run, you can now safely unplug the USB cable."
echo " - Your phone must remain on the same Wi-Fi network for future connections."
echo " - Run this script anytime to reconnect to your device over TCP/IP."
echo " - If the connection fails, ensure your firewall allows traffic on port $PORT."
echo

echo "✅ WSL is now configured to use adb over TCP/IP."
