# PM2 Cheatsheet (Process Manager)

PM2 runs inside the Docker container. It keeps background agents (like OpenClaw) alive, handles auto-restarts on crashes, and provides real-time logs.

**Accessing PM2:**
Always run these commands *inside* the container:
```bash
make zshell
```

**Monitoring & Logs:**
```bash
pm2 status       # List all background processes with CPU/RAM stats
pm2 monit        # Open interactive terminal dashboard (stats + live logs)
pm2 logs         # Tail logs for all processes
```

**Manage Agents (Lifecycle):**
```bash
pm2 restart openclaw   # Apply new OpenClaw configs without restarting Docker
pm2 stop openclaw      # Temporarily kill the agent
pm2 delete openclaw    # Remove agent from PM2 management
```

**Manual Start (First time setup):**
*(Note: `entrypoint.sh` does this automatically on boot if OpenClaw is installed)*
```bash
pm2 start "openclaw gateway run --force" --name "openclaw" --exp-backoff-restart-delay=100
```
