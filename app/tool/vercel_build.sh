#!/usr/bin/env bash
# Builds the web test preview of the app on Vercel, which has no Flutter
# installed. Used only by app/vercel.json. The Android APK is the real product.
set -euo pipefail

FLUTTER_VERSION=3.50.0
FLUTTER_HOME=/tmp/flutter

if [ ! -x "$FLUTTER_HOME/bin/flutter" ]; then
  archive="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz"
  if ! curl -fsSL "$archive" | tar -xJ -C /tmp; then
    rm -rf "$FLUTTER_HOME"
    git clone --depth 1 --branch "$FLUTTER_VERSION" https://github.com/flutter/flutter.git "$FLUTTER_HOME"
  fi
fi

git config --global --add safe.directory "$FLUTTER_HOME"
export PATH="$FLUTTER_HOME/bin:$PATH"

flutter config --no-analytics > /dev/null
flutter pub get
flutter build web --release
