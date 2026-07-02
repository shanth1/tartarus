#!/bin/bash
set -e
echo "==> installing ai agents and clis..."
npm install -g opencode-ai || npm install -g @opencode/cli || true

curl -LsSf https://astral.sh/uv/install.sh | env UV_INSTALL_DIR="/usr/local/bin" sh
uv tool install aider-chat || true

echo "==> ai tools installed successfully."
