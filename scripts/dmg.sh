#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

echo "==> Building SpotTerm release bundle..."
./scripts/build.sh release

APP_PATH="build/SpotTerm.app"
DMG_PATH="build/SpotTerm.dmg"
VOL_NAME="SpotTerm"

if [ ! -d "${APP_PATH}" ]; then
    echo "ERROR: ${APP_PATH} not found!"
    exit 1
fi

TMP_DIR="$(mktemp -d -t spotterm_dmg_XXXXXX)"
trap 'rm -rf "${TMP_DIR}"' EXIT

echo "==> Staging DMG files..."
cp -R "${APP_PATH}" "${TMP_DIR}/SpotTerm.app"
ln -s /Applications "${TMP_DIR}/Applications"

echo "==> Creating compressed disk image (.dmg)..."
rm -f "${DMG_PATH}"
hdiutil create \
    -volname "${VOL_NAME}" \
    -srcfolder "${TMP_DIR}" \
    -ov \
    -format UDZO \
    "${DMG_PATH}"

echo "✓ DMG created successfully at: ${DMG_PATH}"
