#!/bin/bash

# Script to fix DWDS (Dart Web DevServer) connection errors
# These errors occur when the browser execution context is destroyed during debugging

echo "Fixing DWDS connection errors..."
echo ""

# 1. Clean Flutter build cache
echo "Step 1: Cleaning Flutter build cache..."
flutter clean

# 2. Get Flutter packages
echo ""
echo "Step 2: Getting Flutter packages..."
flutter pub get

# 3. Clear web build artifacts
echo ""
echo "Step 3: Clearing web build artifacts..."
rm -rf build/web
rm -rf .dart_tool/flutter_build

# 4. Instructions
echo ""
echo "=========================================="
echo "Next steps:"
echo "=========================================="
echo "1. Stop any running Flutter apps (Ctrl+C)"
echo "2. Close all browser tabs with your Flutter web app"
echo "3. Restart your Flutter app with: flutter run -d chrome"
echo ""
echo "Note: DWDS errors are usually non-fatal warnings."
echo "They occur when:"
echo "  - The browser tab is refreshed during debugging"
echo "  - Hot reload/restart is performed"
echo "  - The browser context is destroyed"
echo ""
echo "These warnings don't prevent your app from running,"
echo "but they disable DevTools deep links in error messages."
echo "=========================================="

