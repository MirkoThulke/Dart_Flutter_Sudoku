#!/bin/bash

# Path to launch.json
LAUNCH_JSON=".vscode/launch.json"

# Get the first connected device ID (USB or TCP/IP)
DEVICE_ID=$(adb devices | awk 'NR>1 && $2=="device" {print $1; exit}')

if [ -z "$DEVICE_ID" ]; then
    echo "No connected Android device found."
    exit 1
fi

echo "Found device: $DEVICE_ID"

# Update launch.json using jq
TMP_FILE=$(mktemp)

jq --arg deviceId "$DEVICE_ID" '
    .configurations |= map(
        if .name | test("docker") or .name | test("host") then
            .deviceId = $deviceId
        else
            .
        end
    )
' "$LAUNCH_JSON" > "$TMP_FILE" && mv "$TMP_FILE" "$LAUNCH_JSON"

echo "launch.json updated with device ID: $DEVICE_ID"

