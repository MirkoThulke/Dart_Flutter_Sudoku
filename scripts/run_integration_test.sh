#!/usr/bin/env bash
set -euo pipefail

# -----------------------------------------------------------
# What an Android-ready integration test pipeline must validate
# ✔️ 1. Flutter doctor (Android toolchain installed)
# ✔️ 2. Android licenses accepted
# ✔️ 3. Android emulator available (headless) OR a physical device over ADB
# ✔️ 4. Integration tests via flutter drive against the Android build
# ✔️ 5. App build checks:
# 
# flutter build apk --release
# flutter build appbundle --release
# Validate signing
# Validate versioning
# Ensure no fatal crashes in startup test
# -----------------------------------------------------------

echo "🚀 Running Flutter Android integration readiness check"


# Find the APK path (assuming it was built by the CI pipeline)
BUILD_MODE="${BUILD_MODE:-debug}"

echo "🔧 Integration test mode: $BUILD_MODE"

if [ "$BUILD_MODE" = "release" ]; then
  APK_GLOB="build/app/outputs/flutter-apk/app-*-release.apk"
else
  APK_GLOB="build/app/outputs/flutter-apk/app-*-debug.apk"
fi

APK_PATH=$(ls $APK_GLOB 2>/dev/null | head -n1)

if [ -z "$APK_PATH" ]; then
  echo "❌ No APK found to install."
  exit 1
fi


BASE_DIR=$(pwd)
REPORT_DIR="$BASE_DIR/integration_test_reports"
mkdir -p "$REPORT_DIR"

ANDROID_RESULT="$REPORT_DIR/android_test_output.json"
ANDROID_LOG="$REPORT_DIR/android_test_errors.log"

# -----------------------------------------------------------
# 0️⃣ Preconditions check
# -----------------------------------------------------------
echo "🔎 Checking for integration tests..."
if [ -z "$(ls integration_test/*_test.dart 2>/dev/null)" ]; then
  echo "⚠️ No integration_test/*_test.dart files found."
  exit 1
fi

# -----------------------------------------------------------
# 1️⃣ Flutter environment diagnostics
# -----------------------------------------------------------
flutter doctor -v
echo "📱 Connected Android devices:"
adb devices || true

if ! adb devices | grep -q "device$"; then
  echo "❌ No Android device/emulator detected."
  echo "You MUST start an emulator inside the Docker container:"
  echo "  $ANDROID_SDK_ROOT -avd test_avd -no-snapshot -noaudio -no-window &"
  exit 1
fi


# -----------------------------------------------------------
# 2️⃣ Build checks
# -----------------------------------------------------------

echo "📝 Build artifacts ready:"

if [ "$BUILD_MODE" = "release" ]; then
  find build/app/outputs -name "*.aab" -print || echo "⚠️ No AABs found in build/app/outputs"
else
  find build/app/outputs -name "*.apk" -print || echo "⚠️ No APKs found in build/app/outputs"
  find build/app/outputs -name "*.aab" -print || echo "⚠️ No AABs found in build/app/outputs"
fi



# -----------------------------------------------------------
# 3️⃣ Run Integration Tests on Android
# -----------------------------------------------------------
echo "🧪 Running Flutter integration tests on Android..."

ANDROID_STATUS=1

# Install but do not build again (assumes APK/AAB already built)

DEVICE_ID=$(adb devices | awk '$2=="device"{print $1; exit}')

if [ -z "$DEVICE_ID" ]; then
  echo "❌ No ready Android device found."
  exit 1
fi

echo "📲 Installing APK on device $DEVICE_ID"
adb install -r "$APK_PATH"
echo "🚗 Running integration tests on device $DEVICE_ID"



flutter drive \
  --driver=integration_test/driver.dart \
  --target=integration_test/basic_app_flow_test.dart \
  -d "$DEVICE_ID" \
  --no-build \
  1> "$ANDROID_RESULT" \
  2> "$ANDROID_LOG" || ANDROID_STATUS=$?

if [ $ANDROID_STATUS -eq 0 ]; then
  echo "✅ Android integration tests passed"

  #checksum check to guarantee integrity of the APK used during tests
  sha256sum "$APK_PATH" > "$REPORT_DIR/apk.sha256" 

else
  echo "❌ Android integration tests failed (exit $ANDROID_STATUS)"
  
  echo "📄 First 40 lines of log:"
  head -n 40 "$ANDROID_LOG"

fi

# -----------------------------------------------------------
# 4️⃣ Final evaluation
# -----------------------------------------------------------
if [ $ANDROID_STATUS -eq 0 ]; then
  echo "🎉 All Android integration tests passed!"
  echo "📄 Report saved to $REPORT_DIR"
  exit 0
else
  echo "⚠️ Integration tests failed."
  exit 1
fi