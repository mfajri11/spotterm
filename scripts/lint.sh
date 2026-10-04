#!/usr/bin/env bash
set -euo pipefail

echo "==> Running strict SwiftLint..."
if ! command -v swiftlint >/dev/null 2>&1; then
    echo "ERROR: swiftlint is required for strict linting."
    exit 1
fi

swiftlint lint --strict
echo "✓ Strict lint check passed!"
