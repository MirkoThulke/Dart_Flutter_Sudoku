#!/usr/bin/env bash
set -e

# =========================================
# Cross-platform Flutter build script
# =========================================

# Load previously saved device info from setup script
DEVICE_IP_FILE="$HOME/.adb_device_ip"
PORT=5555
if [ -f "$DEVICE_IP_FILE" ]; then
    DEVICE_IP=$(cat "$DEVICE_IP_FILE")
    echo "📡 Loaded device IP: $DEVICE_IP"
else
    echo "⚠️ No saved device IP found. Run your setup script first."
fi

# Detect environment
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    ENV_TYPE="WSL"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ENV_TYPE="WINDOWS"
else
    ENV_TYPE="LINUX"
fi
echo "Detected environment: $ENV_TYPE"

# Select proper ADB command
if [[ "$ENV_TYPE" == "WSL" ]]; then
    WIN_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
    export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037
    ADB_CMD="adb.exe -a -P 5037"
else
    ADB_CMD="adb"
fi

# Parse arguments
FLUTTER_MODE=${1:-release}
CLEAN_BUILD=false
[[ "$2" == "--clean" ]] && CLEAN_BUILD=true

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
cd "$PROJECT_ROOT" || { echo "❌ Failed to cd to project root: $PROJECT_ROOT"; exit 1; }
echo "📂 Current directory: $(pwd)"


# =====================================================================
# This script detects whether it runs inside:
# Docker
# WSL2
# Linux host
# … and generates android/local.properties accordingly.
# =====================================================================
echo "🔧 Regenerating local.properties..."
chmod +x ./scripts/generate_local_properties.sh
./scripts/generate_local_properties.sh


# 🔍 Ensure CMake exists in WSL
if [[ "$ENV_TYPE" == "WSL" ]]; then
  if ! command -v cmake >/dev/null 2>&1; then
    echo "❌ CMake not found in WSL. Install it with:"
    echo "   sudo apt update && sudo apt install cmake"
    exit 1
  fi
fi


# 🧩 Force CMake path for WSL builds
if [[ "$ENV_TYPE" == "WSL" ]]; then
  echo "🐧 Running inside WSL – ensuring Gradle uses Linux cmake"
  LOCAL_PROPS="$PROJECT_ROOT/android/local.properties"
  mkdir -p "$(dirname "$LOCAL_PROPS")"
  grep -q '^cmake\.dir=' "$LOCAL_PROPS" 2>/dev/null && sed -i '/^cmake\.dir=/d' "$LOCAL_PROPS"
  echo "cmake.dir=/usr/bin" >> "$LOCAL_PROPS"
  echo "✅ Ensured local.properties has cmake.dir=/usr/bin"
fi

# Verify Flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "❌ Flutter not found in PATH"
  exit 1
fi

# Fetch dependencies
echo "📦 Fetching Flutter dependencies..."
flutter pub get

# Clean build if requested
if [ "$CLEAN_BUILD" = true ]; then
  echo "🧹 Performing a clean build..."
  flutter clean
fi

# Build APK
echo "🏗️ Building Flutter APK in $FLUTTER_MODE mode..."
flutter build apk --$FLUTTER_MODE

# Locate APK
APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLUTTER_MODE.apk"
if [ ! -f "$APK_PATH" ]; then
  echo "❌ APK not found at expected location: $APK_PATH"
  exit 1
fi

echo "✅ Flutter build finished!"
echo "📦 APK located at: $APK_PATH"

# Switch USB device to TCP/IP mode automatically
USB_DEVICE=$($ADB_CMD devices | awk 'NR>1 && /device$/{print $1; exit}')
if [[ -n "$USB_DEVICE" ]]; then
    echo "📱 USB device detected: $USB_DEVICE"
    $ADB_CMD -s "$USB_DEVICE" tcpip "$PORT" || true
    echo "✅ TCP/IP mode enabled on port $PORT. You can unplug the USB cable."
fi

# Try reconnecting if no device detected
if ! $ADB_CMD devices | grep -E "device$|:5555\s*device" >/dev/null; then
    echo "⚠️ No active device found — trying to reconnect over TCP/IP..."
    $ADB_CMD connect "$DEVICE_IP:$PORT" >/dev/null 2>&1
    sleep 2
fi

# display the connection mode automatically
if $ADB_CMD devices | grep -E "$DEVICE_IP|:5555\s*device" >/dev/null; then
    echo "🌐 Connected over Wi-Fi ($DEVICE_IP)"
else
    echo "🔌 Connected via USB"
fi

# Install APK
if $ADB_CMD devices | grep -E "device$|:5555\s*device" >/dev/null; then
    echo "📲 Installing app..."
    if ! $ADB_CMD install -r "$APK_PATH"; then
        echo "⚠️ Failed to install. Trying uninstall + reinstall..."
        PACKAGE_NAME=$(aapt dump badging "$APK_PATH" | grep "package: name=" | awk -F"'" '{print $2}')
        $ADB_CMD uninstall "$PACKAGE_NAME" || true
        $ADB_CMD install -r "$APK_PATH"
    fi
else
    echo "❌ Still no device connected. Skipping install."
fi
