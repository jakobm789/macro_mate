#!/usr/bin/env bash
set -e
VERSION=3.44.1
ARCHIVE="flutter_linux_${VERSION}-stable.tar.xz"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"
SDK_DIR="flutter_sdk"

INSTALLED_VERSION=""
if [ -x "$SDK_DIR/bin/flutter" ]; then
  INSTALLED_VERSION="$("$SDK_DIR/bin/flutter" --version 2>/dev/null | head -n 1 | awk '{print $2}')"
fi

if [ "$INSTALLED_VERSION" != "$VERSION" ]; then
  rm -rf "$SDK_DIR"
  echo "Downloading Flutter $VERSION..."
  curl -L "$URL" -o "$ARCHIVE"
  mkdir -p "$SDK_DIR"
  tar xf "$ARCHIVE" -C "$SDK_DIR" --strip-components=1
  rm "$ARCHIVE"
fi

echo "Flutter installed in $SDK_DIR"

cat <<PATHRC
Add the following line to your shell profile to use this Flutter version:
  export PATH="$(pwd)/$SDK_DIR/bin:\$PATH"
PATHRC
