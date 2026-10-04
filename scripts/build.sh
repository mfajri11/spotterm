#!/usr/bin/env bash
set -euo pipefail

CONFIGURATION="${1:-release}"
echo "==> Building SpotTerm (${CONFIGURATION})..."

swift build -c "${CONFIGURATION}"

BIN_DIR="$(swift build -c "${CONFIGURATION}" --show-bin-path)"
EXECUTABLE="${BIN_DIR}/SpotTerm"

if [ ! -f "${EXECUTABLE}" ]; then
    echo "ERROR: Compiled executable not found at ${EXECUTABLE}"
    exit 1
fi

APP_DIR="build/SpotTerm.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

rm -rf "${APP_DIR}"
mkdir -p "${MACOS_DIR}" "${RESOURCES_DIR}"

cp "${EXECUTABLE}" "${MACOS_DIR}/SpotTerm"
cp "Resources/Info.plist" "${CONTENTS_DIR}/Info.plist"

# Copy any dependency resource bundles if present
find "${BIN_DIR}" -maxdepth 1 -name "*.bundle" -exec cp -R {} "${RESOURCES_DIR}/" \; 2>/dev/null || true

echo "==> Signing application bundle (ad-hoc)..."
codesign --force --deep --sign - "${APP_DIR}"

echo "✓ Application built successfully at: ${APP_DIR}"
