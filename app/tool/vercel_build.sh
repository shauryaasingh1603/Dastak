#!/usr/bin/env bash
# Builds the volunteers' website (the app, compiled for the browser) on
# Vercel, which has no Flutter installed. Used by app/vercel.json.
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
# Everything is served from this site (no Google CDN) with hashed file names,
# so the offline helper sw.js can keep the whole app on the phone.
flutter build web --release --no-web-resources-cdn --web-content-hash
dart run tool/make_sw.dart build/web
