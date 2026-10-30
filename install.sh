#!/usr/bin/env bash

set -euo pipefail

REPO="aematosy/apptrak-releases"
ASSET="apptrak-macos-arm64.tar.gz"
INSTALL_DIR="${HOME}/.local/bin"
BINARY="${INSTALL_DIR}/apptrak"

echo
echo "APPTRAK · INSTALLER"
echo "────────────────────────────────────────"
echo

ARCH="$(uname -m)"

if [ "$ARCH" != "arm64" ]; then
  echo "Error: esta distribución requiere macOS Apple Silicon (arm64)."
  exit 1
fi

mkdir -p "$INSTALL_DIR"

TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}

trap cleanup EXIT

echo "Downloading latest Apptrak..."

curl -fL   "https://github.com/${REPO}/releases/latest/download/${ASSET}"   -o "${TMP_DIR}/${ASSET}"

tar -xzf   "${TMP_DIR}/${ASSET}"   -C "$TMP_DIR"

mv   "${TMP_DIR}/apptrak-macos-arm64"   "$BINARY"

chmod +x "$BINARY"

echo
echo "Installed:"
echo "  $BINARY"
echo

case ":$PATH:" in
  *":$INSTALL_DIR:"*)
    ;;
  *)
    echo "Add Apptrak to your PATH:"
    echo
    echo '  export PATH="$HOME/.local/bin:$PATH"'
    echo
    ;;
esac

echo "Run:"
echo
echo "  apptrak"
echo
