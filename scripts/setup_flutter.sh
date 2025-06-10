#!/usr/bin/env bash
set -e
VERSION=3.32.1
ARCHIVE="flutter_linux_${VERSION}-stable.tar.xz"
URL="https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/${ARCHIVE}"
SDK_DIR="flutter_sdk"

if [ ! -d "$SDK_DIR" ]; then
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
