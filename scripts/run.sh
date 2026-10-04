#!/usr/bin/env bash
set -euo pipefail

echo "==> Building debug artifact..."
./scripts/build.sh debug

echo "==> Stopping any previously running SpotTerm instance..."
killall SpotTerm 2>/dev/null || true
sleep 0.3

echo "==> Launching SpotTerm.app..."
open build/SpotTerm.app

echo "✓ SpotTerm is running! Press ⌥Space to summon/dismiss the floating terminal HUD."
