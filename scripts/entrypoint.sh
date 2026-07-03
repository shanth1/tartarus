#!/bin/bash
set -e

pm2 ping > /dev/null

if command -v openclaw &> /dev/null; then
    echo "==> Starting openclaw via PM2..."
    pm2 start "openclaw gateway run --force" --name "openclaw" --exp-backoff-restart-delay=100
else
    echo "==> WARNING: openclaw not found. Skipping auto-start."
fi

exec pm2 logs
