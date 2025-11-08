#!/usr/bin/env bash
set -e

# =========================================
# Robust WSL-native ADB over TCP/IP setup for Flutter
# =========================================

DEVICE_IP_FILE="$HOME/.adb_device_ip"
PORT=5555

echo "ℹ️ Detecting Windows host IP from WSL..."
WIN_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
if [ -z "$WIN_IP" ]; then
    echo "❌ Could not detect Windows host IP."
    exit 1
fi
echo "ℹ️ Detected Windows host IP: $WIN_IP"

# Set ADB server socket
export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037
echo "✅ Set ADB_SERVER_SOCKET for this session: $ADB_SERVER_SOCKET"

# Persist for future sessions
if ! grep -q "ADB_SERVER_SOCKET" ~/.bashrc; then
    echo "export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037" >> ~/.bashrc
    echo "✅ Added ADB_SERVER_SOCKET to ~/.bashrc for future sessions"
fi

# 1️⃣ Ensure adb is installed
if ! command -v adb >/dev/null 2>&1; then
    echo "❌ adb not found. Install with: sudo apt install adb"
    exit 1
fi

# 2️⃣ Stop any running adb server
echo "🔄 Stopping any running adb server in WSL..."
adb kill-server || true

# 3️⃣ Start adb server
echo "🔄 Starting adb server in WSL..."
adb start-server || true

# 4️⃣ Firewall check for ADB port (Windows host)
echo "ℹ️ Checking firewall connectivity to Windows host ADB..."
nc -z -v -w 3 "$WIN_IP" 5037 >/dev/null 2>&1 || {
    echo "⚠️ Cannot connect to Windows host ADB at $WIN_IP:5037."
    echo "💡 Ensure Windows firewall allows inbound connections to port 5037 from WSL."
    read -p "Press Enter to continue anyway or Ctrl+C to abort..."
}

# 5️⃣ Detect USB-connected device (first-time TCP setup)
USB_DEVICE=$(adb devices | grep -v "List of devices" | grep -v "offline" | grep -v "unauthorized" | awk '{print $1}' | head -n 1 || true)
if [ -n "$USB_DEVICE" ]; then
    echo "📱 USB device detected: $USB_DEVICE"
    if [ ! -f "$DEVICE_IP_FILE" ]; then
        echo "🔄 Switching device to TCP/IP mode on port $PORT..."
        adb -s "$USB_DEVICE" tcpip $PORT || echo "⚠️ Failed to switch device to TCP/IP mode"
    fi
else
    echo "⚠️ No USB device detected. Assuming TCP/IP mode was enabled previously."
fi

# 6️⃣ Detect device IP
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

# 7️⃣ Connect to device via TCP/IP
echo "🔄 Connecting to device $DEVICE_IP:$PORT..."
adb connect "$DEVICE_IP:$PORT" || echo "⚠️ Could not connect to device $DEVICE_IP:$PORT"

# 8️⃣ List all devices
echo "🔄 Listing all devices..."
adb devices -l || true

echo "✅ WSL is now configured to use adb over TCP/IP."
