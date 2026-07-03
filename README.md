<div align="center">
  <img src="assets/tartarus.jpg" alt="tartarus logo" width="200" height="200" style="border-radius: 10%;">
  <h1>tartarus</h1>
  <p>sandboxed dev-environment & ai agents</p>
</div>

---

### Makefile Cheatsheet
| command | action |
|---|---|
| `make env` | create `.env` |
| `make build` | build base image |
| `make init` | first-time setup (zsh, agents) |
| `make start` | run daemon |
| `make stop` / `restart` | stop / reload env vars |
| `make zshell` | enter container |
| `make logs` / `status` | view background logs / check htop stats |
| `make check-sec` | verify mac isolation |

### OrbStack Reminders
* **Security:** Remove ALL default mounts (including `~`) in OrbStack GUI -> Settings -> File Sharing.
* **Network routing:** To access Mac host from container (e.g. Ollama, Postgres), always use: `host.orb.internal`
