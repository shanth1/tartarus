# OpenClaw Cheatsheet

State is permanently saved to `.openclaw_state/` in the project root via Docker volumes.
Daemon starts automatically in the background on `make start` via `entrypoint.sh`.

**First Time Init (inside container):**
```bash
# Skip systemd setup when asked
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw onboard
```

**Basic Configs:**
```bash
openclaw config set gateway.mode "local"
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.mode "polling"
openclaw skills install core/messaging
```

**Connect Local Model:**
```bash
openclaw config set gateway.bind lan
openclaw config set llm.provider "openai"
openclaw config set llm.base_url "http://host.orb.internal:11434/v1"
openclaw config set llm.api_key "ollama"
openclaw config set agents.defaults.model.primary "qwen3.6:27b-mlx"
```
*Note: Run `make restart` on host to apply config changes to the background daemon.*

**Commands**
```bash
openclaw gateway start
openclaw gateway stop
openclaw gateway restart
openclaw gateway status
openclaw logs
openclaw dashboard
openclaw tui
openclaw doctor
```
