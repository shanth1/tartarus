**Supervisor Quick Cheat Sheet**

**1. Basic Commands**
*   `supervisorctl status` — Show status of all processes
*   `supervisorctl start <name>` — Start a process (use `all` for all processes)
*   `supervisorctl stop <name>` — Stop a process
*   `supervisorctl restart <name>` — Restart a process
*   `supervisorctl tail -f <name>` — View live logs (stdout)
*   `supervisorctl tail -f <name> stderr` — View live error logs

**2. Applying Config Changes** (Run these after editing a `.conf` file)
*   `supervisorctl reread` — Read config changes (won't restart apps)
*   `supervisorctl update` — Apply changes (restarts only affected apps)
*   `supervisorctl reload` — Restart the entire Supervisor and all apps

**3. Config Files Location**
*   Add your `app.conf` files here: `/etc/supervisor/conf.d/`

**4. Interactive Mode**
*   Just type `supervisorctl` to enter the interactive shell (type `help` to see commands, `exit` to leave).
