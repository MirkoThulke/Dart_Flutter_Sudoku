#!/usr/bin/env bash
set -e

# Detect environment
if grep -qEi "(Microsoft|WSL)" /proc/version &> /dev/null; then
    ENV_TYPE="WSL"
elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" ]]; then
    ENV_TYPE="WINDOWS"
else
    ENV_TYPE="LINUX"
fi
echo "Detected environment: $ENV_TYPE"

# Try to get a physical Android device ID (prefer non-emulator)
DEVICE_ID=$(adb devices | awk 'NR>1 && $2=="device" && $1 !~ /emulator/ {print $1; exit}')

# If no physical device, fallback to the first available Flutter device
if [[ -z "$DEVICE_ID" ]]; then
    echo "⚠️ No physical device found, checking Flutter devices..."
    DEVICE_ID=$(flutter devices --machine | grep '"id":' | awk -F'"' '{print $4}' | head -n1)
fi

# Validate device ID
if [[ -z "$DEVICE_ID" ]]; then
    echo "❌ No connected Flutter or Android device found."
    exit 1
fi

echo "📱 Using device ID: $DEVICE_ID"

# Update VS Code launch.json
LAUNCH_JSON="$PWD/.vscode/launch.json"
if [[ -f "$LAUNCH_JSON" ]]; then
    sed -i.bak -E "s/\"deviceId\":\s*\"[^\"]*\"/\"deviceId\": \"$DEVICE_ID\"/" "$LAUNCH_JSON"
    echo "🎯 launch.json updated with device ID: $DEVICE_ID"
else
    echo "⚠️ launch.json not found, skipping update"
fi


