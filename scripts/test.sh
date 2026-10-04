#!/usr/bin/env bash
set -euo pipefail

echo "==> Running SpotTerm test suite..."
swift test
echo "✓ All tests passed!"
