# local models (ollama) integration

running local models securely on the mac host and accessing them from the isolated `tartarus` container.

## 1. host setup (macos)
to run ollama as a persistent background daemon that survives reboots, use homebrew services. this uses the native macos `launchd` system.

```bash
# install native mac binary
brew install ollama

# start persistent background service (runs on boot)
brew services start ollama
```

## 2. pull required models (macos terminal)
download the models you want to keep in memory (m2 ultra can handle large models easily).
```bash
# for coding / autonomous agents (metal optimized)
ollama pull qwen3.6:27b-mlx

# for rag / vector embeddings (absolute top for russian language)
ollama pull bge-m3
```

## 3. basic usage & testing (macos terminal)
you can chat with your models directly from your mac terminal without any agents, just to test their logic:
```bash
# start an interactive chat session
ollama run qwen3.6:27b-mlx

# type your prompt, e.g.: "напиши интерфейс для работы с базой данных на go"
# type /bye to exit the chat
```

## 4. verify container connection
tartarus is isolated, but orbstack provides a secure bridge to the host via `host.orb.internal`.

1. enter your container:
   ```bash
   make zshell
   ```
2. ping the host service to check installed models:
   ```bash
   curl http://host.orb.internal:11434/api/tags
   ```
3. test text generation directly via api (from inside tartarus):
   ```bash
   curl http://host.orb.internal:11434/api/generate -d '{
     "model": "qwen3.6:27b-mlx",
     "prompt": "why is the sky blue? short answer",
     "stream": false
   }'
   ```

## 5. opencode configuration
`opencode` expects an openai-compatible api. ollama provides this automatically at the `/v1` path.

in your tartarus `.env` file, define the route and a dummy key (opencode requires a key string, even if ollama ignores it):
```env
OLLAMA_BASE_URL=http://host.orb.internal:11434/v1
OLLAMA_API_KEY=ollama
```

when running `opencode` inside tartarus, map these to the standard openai variables:
```bash
# option a: pass variables directly in the command
OPENAI_BASE_URL=$OLLAMA_BASE_URL OPENAI_API_KEY=$OLLAMA_API_KEY \
opencode -m qwen3.6:27b-mlx "создай crud приложение на go fiber в текущей папке"

# option b: export them for the whole session (you can add this to your .zshrc)
export OPENAI_BASE_URL=$OLLAMA_BASE_URL
export OPENAI_API_KEY=$OLLAMA_API_KEY
opencode -m qwen3.6:27b-mlx "сделай рефакторинг файла main.go"
```

## 6. management & troubleshooting commands (macos terminal)
* restart daemon (fixes "requires newer version" errors): `brew services restart ollama`
* stop the background service: `brew services stop ollama`
* view ollama background logs: `tail -f /opt/homebrew/var/log/ollama.log`
* check which models are currently loaded in your m2 ram/vram: `ollama ps`
