#!/usr/bin/env bash
set -euo pipefail

EXPORT_URL="https://md.juki.app/api/export/MD-voQ"
CONTENT_DIR="$(cd "$(dirname "$0")/.." && pwd)/"
DOCS_DIR="$CONTENT_DIR/docs"
TMP_ZIP=$(mktemp /tmp/pollar-docs-XXXXXX.zip)
TMP_DIR=$(mktemp -d /tmp/pollar-docs-XXXXXX)

cleanup() {
  rm -f "$TMP_ZIP"
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Downloading export from $EXPORT_URL..."
curl -fsSL "$EXPORT_URL" -o "$TMP_ZIP"

echo "Removing $DOCS_DIR..."
rm -rf "$DOCS_DIR"

echo "Extracting zip..."
unzip -q "$TMP_ZIP" -d "$TMP_DIR"

# Find the docs folder inside the extracted content
EXTRACTED_DOCS=$(find "$TMP_DIR" -maxdepth 2 -type d -name "docs" | head -n 1)

if [ -z "$EXTRACTED_DOCS" ]; then
  echo "Error: no 'docs' folder found in the zip" >&2
  exit 1
fi

echo "Moving docs to $DOCS_DIR..."
mv "$EXTRACTED_DOCS" "$DOCS_DIR"

echo "Done. Docs synced to $DOCS_DIR"
