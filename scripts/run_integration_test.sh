#!/usr/bin/env bash
set -euo pipefail

echo "🚀 Running Flutter integration tests (Desktop + Web)"

BASE_DIR=$(pwd)
DESKTOP_RESULT="$BASE_DIR/integration_test/desktop_test_report.json"
WEB_RESULT="$BASE_DIR/integration_test/web_test_report.json"
TEST_FILES="integration_test/*_test.dart"

# -----------------------------------------------------------
# 0️⃣ Check test files exist
# -----------------------------------------------------------
if [ -z "$(ls $TEST_FILES 2>/dev/null)" ]; then
  echo "⚠️ No integration test files found in $TEST_FILES"
  exit 1
fi

# -----------------------------------------------------------
# 1️⃣ Diagnostics
# -----------------------------------------------------------
echo "🧪 Flutter doctor:"
flutter doctor -v

echo "🧪 Installed devices:"
flutter devices || true

# -----------------------------------------------------------
# 2️⃣ Run integration tests on Linux desktop (WidgetTester)
# -----------------------------------------------------------
echo "🖥️ Running Linux desktop integration tests..."
flutter test --machine $TEST_FILES 1> "$DESKTOP_RESULT" 2> desktop_test_errors.log
DESKTOP_STATUS=${PIPESTATUS[0]:-1}

if [ $DESKTOP_STATUS -eq 0 ]; then
  echo "✅ Desktop tests passed"
else
  echo "❌ Desktop tests failed (exit $DESKTOP_STATUS)"
fi

if [ -f "$DESKTOP_RESULT" ]; then
  echo "📄 Desktop JSON report created: $DESKTOP_RESULT"
  echo "📊 Preview (first 20 lines):"
  head -n 20 "$DESKTOP_RESULT"
fi

# -----------------------------------------------------------
# 3️⃣ Run integration tests on headless Chrome (Web)
# -----------------------------------------------------------
echo "🌐 Running headless Chrome web integration tests..."

WEB_STATUS=1  # default (fail-safe)

if ! command -v google-chrome >/dev/null 2>&1; then
  echo "⚠️ Chrome not found, skipping web tests"
  WEB_STATUS=0
else
  # Keep your flutter drive invocation, just safer handling
  flutter drive \
    --driver=integration_test/driver.dart \
    --target=integration_test/basic_app_flow_test.dart \
    -d web-server \
    --browser-name=chrome \
    1> "$WEB_RESULT" \
    2> "$ERROR_DIR/web_errors.log" || WEB_STATUS=$?

  if [ $WEB_STATUS -eq 0 ]; then
    echo "✅ Web tests passed"
  else
    echo "❌ Web tests failed (exit $WEB_STATUS)"
    echo "📄 First 20 lines of web error log:"
    head -n 20 "$ERROR_DIR/web_errors.log"
  fi
fi

# -----------------------------------------------------------
# 4️⃣ Overall exit
# -----------------------------------------------------------
if [ $DESKTOP_STATUS -eq 0 ] && [ $WEB_STATUS -eq 0 ]; then
  echo "🎉 All integration tests passed!"
  exit 0
else
  echo "⚠️ Some integration tests failed."
  exit 1
fi
