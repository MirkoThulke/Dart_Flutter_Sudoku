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

#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Running Flutter Android integration readiness check"

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
echo "🧪 flutter doctor -v"
flutter doctor -v

echo "📡 Checking Android toolchain..."
flutter doctor --android-licenses || true

echo "📱 Connected Android devices:"
adb devices || true

if ! adb devices | grep -q "device$"; then
  echo "❌ No Android device/emulator detected."
  echo "You MUST start an emulator inside the Docker container:"
  echo "  $ANDROID_HOME/emulator/emulator -avd test_avd -no-snapshot -noaudio -no-window &"
  exit 1
fi

# -----------------------------------------------------------
# 2️⃣ Build checks
# -----------------------------------------------------------
echo "⚙️ Building Android APK (release mode)..."
flutter build apk --release

echo "📦 Building Android AppBundle (Play Store release)..."
flutter build appbundle --release

echo "📝 Build artifacts ready:"
ls -lh build/app/outputs/**/*.aab || true
ls -lh build/app/outputs/**/*.apk || true

# -----------------------------------------------------------
# 3️⃣ Run Integration Tests on Android
# -----------------------------------------------------------
echo "🧪 Running Flutter integration tests on Android..."

ANDROID_STATUS=1

flutter drive \
  --driver=integration_test/driver.dart \
  --target=integration_test/basic_app_flow_test.dart \
  -d $(adb devices | awk 'NR==2{print $1}') \
  1> "$ANDROID_RESULT" \
  2> "$ANDROID_LOG" || ANDROID_STATUS=$?

if [ $ANDROID_STATUS -eq 0 ]; then
  echo "✅ Android integration tests passed"
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
