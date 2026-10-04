#!/usr/bin/env bash
set -euo pipefail

echo "=========================================="
echo " Running SpotTerm CI Pipeline Verification"
echo "=========================================="

echo "Step 1: Check environment & tools"
./scripts/setup.sh

echo "Step 2: Strict SwiftLint check"
./scripts/lint.sh

echo "Step 3: Run unit tests"
./scripts/test.sh

echo "Step 4: Build release application bundle"
./scripts/build.sh release

echo "=========================================="
echo "✓ ALL CHECKS PASSED SUCCESSFULLY!"
echo "=========================================="
