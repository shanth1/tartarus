#!/bin/bash
set -e

echo "==> Cleaning stale session locks and spoolers..."
rm -f /root/.openclaw/agents/main/sessions/*.lock 2>/dev/null || true
rm -rf /root/.openclaw/telegram/ingress-spool-default/* 2>/dev/null || true

if command -v openclaw &> /dev/null; then
    echo "==> Starting openclaw..."
    exec openclaw gateway run --force
else
    echo "==> OpenClaw not found. Keeping container alive..."
    exec tail -f /dev/null
fi

exec pm2 logs
