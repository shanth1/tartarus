# openclaw cheatsheet

> TODO: update and fix

## 1. initial setup (inside container)
```bash
# run interactive setup (skip systemd, provide telegram token)
openclaw onboard
```

## 2. apply required config overrides
```bash
openclaw config set gateway.mode "local"
openclaw config set agents.defaults.workspace "/workspace/lifeos/data"
openclaw config set agents.defaults.model.primary "qwen3.6:27b-mlx"
openclaw config set llm.provider "openai"
openclaw config set llm.base_url "http://host.orb.internal:11434/v1"
openclaw config set llm.api_key "ollama"
openclaw config set channels.telegram.enabled true
openclaw config set channels.telegram.mode "polling"

# allow agent to initiate messages
openclaw skills install core/messaging
```

## 3. link state to mounted workspace (for obsidian access)
```bash
mkdir -p /workspace/lifeos/data
mv /root/.openclaw/workspace/* /workspace/lifeos/data/
mv /root/.openclaw/openclaw.json /workspace/lifeos/openclaw.json
ln -s /workspace/lifeos/openclaw.json /root/.openclaw/openclaw.json
```

## 4. pm2 management
```bash
# install supervisor
npm install -g pm2

# start openclaw daemon
pm2 start "openclaw gateway run --force" --name "openclaw"
pm2 save

# monitor logs
pm2 logs openclaw

# basic controls
pm2 status
pm2 restart openclaw
pm2 stop openclaw
pm2 delete openclaw

# kill all node/openclaw processes if ports hang
pm2 kill
pkill -9 -f openclaw
