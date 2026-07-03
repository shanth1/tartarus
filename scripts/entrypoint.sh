#!/bin/bash
set -e

if command -v openclaw &> /dev/null; then
    openclaw gateway run --force &
fi

exec tail -f /dev/null
