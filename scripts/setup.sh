#!/usr/bin/env bash
set -euo pipefail

echo "==> Setting up SpotTerm development toolchain..."

if ! command -v swift >/dev/null 2>&1; then
    echo "ERROR: Swift toolchain not found. Please install Xcode or Swift 6 command line tools."
    exit 1
fi
echo "✓ Swift detected: $(swift --version | head -n 1)"

if command -v swiftlint >/dev/null 2>&1; then
    echo "✓ SwiftLint detected: $(swiftlint version)"
else
    echo "⚠ SwiftLint not found. Install via: brew install swiftlint"
fi

if command -v swift-format >/dev/null 2>&1; then
    echo "✓ swift-format detected: $(swift-format --version 2>&1 | head -n 1)"
else
    echo "⚠ swift-format not found (optional). Install via: brew install swift-format"
fi

echo "==> Resolving Swift package dependencies..."
swift package resolve

echo "==> Setup complete!"
