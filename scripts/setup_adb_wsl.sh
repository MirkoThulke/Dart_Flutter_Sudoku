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
# Use Windows adb.exe in WSL
if [[ "$(grep -qEi "(Microsoft|WSL)" /proc/version && echo WSL)" == "WSL" ]]; then
    export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037
    ADB_CMD="adb.exe -a -P 5037"
    echo "✅ Set ADB_SERVER_SOCKET for this session: $ADB_SERVER_SOCKET"
else
    ADB_CMD="adb"
fi

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


# 🧠 Extra Check: Ensure Windows adb.exe is running correctly
echo "🩺 Checking if adb.exe is running on Windows..."
if powershell.exe 'Get-Process -Name adb -ErrorAction SilentlyContinue' >/dev/null 2>&1; then
    echo "✅ Windows adb.exe process detected."
else
    echo "⚠️ No adb.exe process detected on Windows."
    echo "💡 You can start it manually from PowerShell with:"
    echo "   adb.exe -a -P 5037 nodaemon server"
    read -p "Press Enter to attempt starting adb.exe automatically via PowerShell or Ctrl+C to abort..."

    # 🚀 Start adb.exe on Windows side (non-blocking, no new window)
    powershell.exe -NoProfile -Command "Start-Process -WindowStyle Hidden -FilePath 'adb.exe' -ArgumentList '-a','-P','5037','nodaemon','server'" >/dev/null 2>&1

    echo "⏳ Waiting a few seconds for adb.exe to start..."
    sleep 3

    # 🧪 Verify adb.exe is running now
    if powershell.exe 'Get-Process -Name adb -ErrorAction SilentlyContinue' >/dev/null 2>&1; then
        echo "✅ adb.exe successfully started on Windows."
    else
        echo "❌ Failed to start adb.exe automatically."
        echo "💡 Try running manually in PowerShell:"
        echo "   adb.exe -a -P 5037 nodaemon server"
    fi
fi

echo "🔍 Checking ADB port binding..."
BIND_STATUS=$(powershell.exe "netstat -ano | findstr 5037" | tr -d '\r' || true)

if echo "$BIND_STATUS" | grep -q "127.0.0.1:5037"; then
    echo "✅ adb.exe is correctly bound to 127.0.0.1:5037"
elif echo "$BIND_STATUS" | grep -q "0.0.0.0:5037"; then
    echo "⚠️ adb.exe is bound to 0.0.0.0:5037 — this can cause conflicts or firewall blocking."
    echo "💡 Fixing: killing adb.exe and restarting with proper binding..."
    powershell.exe "taskkill /IM adb.exe /F" >/dev/null 2>&1 || true
    sleep 1
    powershell.exe -NoProfile -Command "Start-Process -WindowStyle Hidden -FilePath 'adb.exe' -ArgumentList '-a','-P','5037','nodaemon','server'" >/dev/null 2>&1
    echo "✅ Restarted adb.exe on Windows."
    sleep 3
else
    echo "⚠️ adb.exe is not listening on 5037 yet."
    echo "💡 You can check manually in PowerShell:"
    echo "   netstat -ano | findstr 5037"
fi

# 🧹 Optional: Check if adb.exe is misbehaving on 0.0.0.0:5037
echo "🧪 Testing ADB connection on Windows side..."
if nc -z -w 2 "$WIN_IP" 5037 >/dev/null 2>&1; then
    echo "✅ ADB on Windows is reachable on $WIN_IP:5037"
else
    echo "⚠️ ADB on Windows might not be listening on the expected interface."
    echo
    echo "💡 Check the ADB binding from PowerShell (on Windows):"
    echo "   netstat -ano | findstr 5037"
    echo "   👉 You should see something like: '127.0.0.1:5037  LISTENING'"
    echo
    echo "   If you see '0.0.0.0:5037' or an error like 'cannot bind', restart ADB manually:"
    echo "     taskkill /IM adb.exe /F"
    echo "     adb.exe -a -P 5037 nodaemon server"
    echo
    echo "💬 After fixing it, press Enter to continue or Ctrl+C to abort..."
    read -p ""
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

# 5️⃣ Ensure no WSL adb server is running (just cleanup)
echo "🔄 Ensuring no adb server is running in WSL..."
pkill -f "adb" >/dev/null 2>&1 || true

# ✅ Verify connectivity to Windows ADB server instead of starting a new one
echo "🔍 Verifying connection to Windows adb.exe..."
if ! adb devices >/dev/null 2>&1; then
    echo "⚠️ Cannot connect to Windows adb.exe at $WIN_IP:5037."
    echo "💡 Make sure Windows adb.exe is running (check in PowerShell with: Get-Process adb)"
    echo "💡 If not, start it manually with: adb.exe -a -P 5037 nodaemon server"
else
    echo "✅ Connected to Windows adb.exe successfully."
fi


# 7️⃣ Detect USB-connected device for first-time TCP/IP setup
USB_DEVICE=$($ADB_CMD devices | grep -v "List of devices" | grep -v "offline" | grep -v "unauthorized" | awk '{print $1}' | head -n 1 || true)

if [ -n "$USB_DEVICE" ]; then
    echo "📱 USB device detected: $USB_DEVICE"

    if [ ! -f "$DEVICE_IP_FILE" ]; then
        echo "🔄 Switching device to TCP/IP mode on port $PORT..."
        $ADB_CMD -s "$USB_DEVICE" tcpip $PORT || echo "⚠️ Failed to switch device to TCP/IP mode"
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
    DEVICE_IP=$($ADB_CMD shell ip -f inet addr show wlan0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -n 1 || true)

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

# 🛡 Robust TCP/IP authorization loop (FINAL FIXED VERSION)
# Sanitize IP (remove hidden whitespace and CR)
DEVICE_IP=$(echo "$DEVICE_IP" | tr -d '[:space:]\r')

MAX_RETRIES=20
SLEEP_INTERVAL=2
RETRY_COUNT=0
CONNECTED_TCP=0

echo "🆕 Attempting TCP/IP connection to $DEVICE_IP:$PORT..."

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
    # Try to connect
    $ADB_CMD connect "$DEVICE_IP:$PORT" >/dev/null 2>&1 || true

    # Clean CRLF output from Windows adb.exe
    CLEAN_DEVICES=$($ADB_CMD devices | tr -d '\r')

    # Check if Wi-Fi device is registered
    if echo "$CLEAN_DEVICES" | grep -E "^$DEVICE_IP(:[0-9]+)?[[:space:]]+device$" >/dev/null; then
        echo "✅ Wi-Fi device connected: $DEVICE_IP:$PORT"
        CONNECTED_TCP=1
        break
    fi

    # Check for USB device (exclude IP-based entries)
    if echo "$CLEAN_DEVICES" | grep -E "^[0-9A-Za-z._-]+[[:space:]]+device$" >/dev/null; then
        echo "📱 USB still connected — waiting for Wi-Fi authorization..."
    fi

    if [ $RETRY_COUNT -eq 0 ]; then
        echo "💡 If prompted on your phone, accept the ADB authorization request."
    fi

    echo "⏳ Waiting for Wi-Fi ADB... (retry $((RETRY_COUNT+1))/$MAX_RETRIES)"
    sleep $SLEEP_INTERVAL
    RETRY_COUNT=$((RETRY_COUNT + 1))
done

# Final verification (clean and correct)
CLEAN_DEVICES=$($ADB_CMD devices | tr -d '\r')

if echo "$CLEAN_DEVICES" | grep -E "^$DEVICE_IP(:[0-9]+)?[[:space:]]+device$" >/dev/null; then
    echo "🎉 TCP/IP ADB is active: $DEVICE_IP:$PORT"
else
    echo "⚠️ Could not connect to $DEVICE_IP:$PORT after $MAX_RETRIES attempts."
    echo "💡 Ensure your phone is unlocked and authorization was accepted."
    echo "💡 You can check manually with:"
    echo "   $ADB_CMD devices"
fi

echo
echo "🔄 Listing all devices..."
echo "$CLEAN_DEVICES"



# 1️⃣1️⃣ List all devices
echo "🔄 Listing all devices..."
$ADB_CMD devices -l || true

# 📝 User instructions
echo
echo "💡 Instructions:"
echo " - If this was the first run, you can now safely unplug the USB cable."
echo " - Your phone must remain on the same Wi-Fi network for future connections."
echo " - Run this script anytime to reconnect to your device over TCP/IP."
echo " - If the connection fails, ensure your firewall allows traffic on port $PORT."
echo


# =========================================
# 12️⃣ Configure WSL CMake for Flutter/Gradle (automatic)
# =========================================

# Detect CMake in WSL
WSL_CMAKE=$(which cmake || true)

if [ -z "$WSL_CMAKE" ]; then
    echo "❌ CMake not found in WSL. Install it with: sudo apt install cmake"
else
    echo "ℹ️ Detected WSL CMake at: $WSL_CMAKE"

    # Export environment variable for this session
    export ANDROID_CMAKE="$WSL_CMAKE"

    # Persist in bashrc for future sessions
    if ! grep -q "ANDROID_CMAKE" ~/.bashrc; then
        echo "export ANDROID_CMAKE=$WSL_CMAKE" >> ~/.bashrc
        echo "✅ Added ANDROID_CMAKE to ~/.bashrc"
    fi

    # Automatically tell Gradle to use this CMake
    export ORG_GRADLE_PROJECT_android_cmake_path="$WSL_CMAKE"
    echo "✅ Gradle will automatically use WSL CMake at: $WSL_CMAKE"

    # Optional: Inform the user
    echo "💡 No manual gradle.properties edit needed. Flutter/Gradle build will pick up CMake from WSL."
fi

# 1️⃣3️⃣ Persist DEVICE_IP in bashrc for future sessions
echo "export DEVICE_IP=$DEVICE_IP" >> ~/.bashrc

echo "✅ WSL is now configured to use adb over TCP/IP and CMake for Flutter/Gradle."
