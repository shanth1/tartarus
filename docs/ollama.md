# Ollama Cheatsheet (Mac Host)

**Lifecycle (Homebrew daemon):**
```bash
brew install ollama
brew services start ollama
brew services stop ollama
brew services restart ollama
```

**Manage Models (Mac Terminal):**
```bash
ollama pull qwen3.6:27b-mlx
ollama run qwen3.6:27b-mlx
ollama ps
```

**Routing for .env (Container -> Mac):**
```env
OLLAMA_BASE_URL=http://host.orb.internal:11434/v1
OLLAMA_API_KEY=ollama
```
