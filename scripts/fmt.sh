#!/usr/bin/env bash
set -euo pipefail

echo "==> Formatting Swift source code..."

if command -v swift-format >/dev/null 2>&1; then
    swift-format format -i -r Sources Tests
    echo "✓ Formatted using swift-format."
elif command -v swiftlint >/dev/null 2>&1; then
    swiftlint --fix
    echo "✓ Formatted using swiftlint autocorrect."
else
    echo "ERROR: Neither swift-format nor swiftlint is available."
    exit 1
fi
