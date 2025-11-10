#!/usr/bin/env bash
set -e

# =========================================
# Cross-platform Flutter build script
# =========================================

# Parse arguments
FLUTTER_MODE=${1:-release}
CLEAN_BUILD=false
if [[ "$2" == "--clean" ]]; then
  CLEAN_BUILD=true
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

# Use Windows adb.exe in WSL
if [[ "$ENV_TYPE" == "WSL" ]]; then
    WIN_IP=$(grep nameserver /etc/resolv.conf | awk '{print $2}')
    export ADB_SERVER_SOCKET=tcp:$WIN_IP:5037
    ADB_CMD="adb.exe -a -P 5037"
else
    ADB_CMD="adb"
fi

# Resolve project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ "$ENV_TYPE" == "WINDOWS" ]]; then
    if [[ "$SCRIPT_DIR" == //wsl$* || "$SCRIPT_DIR" == \\\\wsl$* ]]; then
        echo "❌ ERROR: UNC path detected. Copy project to a Windows path."
        exit 1
    fi
    PROJECT_ROOT="$SCRIPT_DIR/.."
else
    PROJECT_ROOT="$(realpath "$SCRIPT_DIR/..")"
fi

cd "$PROJECT_ROOT" || { echo "❌ Failed to cd to project root: $PROJECT_ROOT"; exit 1; }
echo "📂 Current directory: $(pwd)"

# 🧩 Force CMake path for WSL builds
if [[ "$ENV_TYPE" == "WSL" ]]; then
  echo "🐧 Running inside WSL – ensuring Gradle uses Linux cmake"
  LOCAL_PROPS="$PROJECT_ROOT/android/local.properties"
  if [ -f "$LOCAL_PROPS" ]; then
      sed -i '/^cmake\.dir=/d' "$LOCAL_PROPS" || true
      echo "cmake.dir=/usr/bin" >> "$LOCAL_PROPS"
      echo "✅ Patched local.properties → cmake.dir=/usr/bin"
  else
      echo "⚠️ local.properties not found — creating it"
      echo "cmake.dir=/usr/bin" > "$LOCAL_PROPS"
      echo "✅ Created local.properties with cmake.dir=/usr/bin"
  fi
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

# Print APK path
APK_PATH="$PROJECT_ROOT/build/app/outputs/flutter-apk/app-$FLUTTER_MODE.apk"
if [ -f "$APK_PATH" ]; then
  echo "✅ Flutter build finished!"
  echo "📦 APK located at: $APK_PATH"
else
  echo "❌ APK not found at expected location: $APK_PATH"
  exit 1
fi

# switch USB device to TCP/IP mode automatically
USB_DEVICE=$($ADB_CMD devices | grep -v "List of devices" | grep -v "offline" | grep -v "unauthorized" | awk '{print $1}' | head -n1)
if [[ -n "$USB_DEVICE" ]]; then
    echo "📱 USB device detected: $USB_DEVICE"
    $ADB_CMD -s "$USB_DEVICE" tcpip 5555
    echo "✅ TCP/IP mode enabled on port 5555. You can unplug the USB cable."
fi

# Install APK automatically if device is connected
if $ADB_CMD devices | grep -q "device$"; then
    echo "📲 Installing app..."
    $ADB_CMD install -r "$APK_PATH" || {
        echo "⚠️ Failed to install. Trying uninstall + reinstall..."
        PACKAGE_NAME=$(aapt dump badging "$APK_PATH" | grep package:\ name | awk -F"'" '{print $2}')
        $ADB_CMD uninstall "$PACKAGE_NAME"
        $ADB_CMD install -r "$APK_PATH"
    }
else
    echo "⚠️ No device connected. Skipping install."
fi
