# Local AI Assistant Setup (MacBook Air M4)

## Recommended Stack

| Component     | Purpose                                  |
| ------------- | ---------------------------------------- |
| Ollama        | Runs local AI models                     |
| Open WebUI    | ChatGPT-style web interface              |
| Qwen2.5-Coder | AI model for coding/OpenShift/Kubernetes |
| Models        | qwen2.5-coder:3b                         |
| Models        | qwen2.5-coder:7b                         |

## Reference

<https://github.com/ml-explore/mlx-lm>
<https://ollama.com/library>
<https://ollama.com/library/qwen2.5-coder>

## Ollama + OpenWebUI

### Ollama

```bash
brew install ollama
ollama --version
ollama ps
ollama serve
ollama run qwen2.5-coder:3b
/bye
```

### Open WebUI

```shell
adam@Fajita-MacBook-M4:~/Documents/code/local-ai$ cat docker-compose.yaml 
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    volumes:
      - open-webui:/app/backend/data
    environment:
      - HF_TOKEN=${HF_TOKEN}
volumes:
  open-webui:
    name: adam_open-webui
```

### Model Management

```bash
ollama list
ollama stop qwen2.5-coder:3b
ollama rm qwen2.5-coder:3b
```

### End Work

```bash
ollama stop qwen2.5-coder:3b
pkill ollama
docker stop open-webui
```

## MLX_LM MacBook Server - ultra optimized

Google it

```shell

sudo python3 -m ensurepip --upgrade
brew install python pipx
pipx install mlx mlx-lm
pipx ensurepath
source ~/.bashrc 
vim .hf_token
export HF_TOKEN=$(cat .hf_token)
echo $HF_TOKEN 
mlx_lm.chat --model mlx-community/Qwen2.5-Coder-7B-Instruct-4bit
mlx_lm.chat --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit
mlx_lm.chat --model mlx-community/Qwen2.5-Coder-1.5B-Instruct-4bit
```

## Hugging Face Token for Faster Downloads

<https://huggingface.co/settings/tokens>

Create Read Only Token

```shell
vim .hf_token
export HF_TOKEN=$(cat .hf_token)
echo $HF_TOKEN 
```

## Shell Scripts

Start script

```shell
adam@Fajita-MacBook-M4:~/Documents/code/local-ai$ cat start-ai.sh 
#!/bin/bash

set -euo pipefail

MODEL="qwen2.5-coder:3b"
COMPOSE_FILE="docker-compose.yaml"

echo "======================================="
echo " Starting Local AI Stack"
echo "======================================="

#
# Load HF token if present
#
if [[ -f ".hf_token" ]]; then
    export HF_TOKEN=$(cat ".hf_token")
    echo "[OK] Loaded Hugging Face token"
fi

#
# Start Ollama if not already running
#
if pgrep -x "ollama" > /dev/null; then
    echo "[OK] Ollama already running"
else
    echo "[INFO] Starting Ollama..."
    nohup ollama serve > "ollama.log" 2>&1 &
    sleep 3
    echo "[OK] Ollama started"
fi

#
# Preload preferred model into memory
#
echo "[INFO] Loading model: $MODEL"
ollama run "$MODEL" "hello" > /dev/null 2>&1 || true

#
# Start Open WebUI
#
echo "[INFO] Starting Open WebUI..."

docker compose -f "$COMPOSE_FILE" up -d

echo "[OK] Open WebUI started"

echo ""
echo "======================================="
echo " AI Stack Ready"
echo "======================================="
echo ""
echo "Open WebUI:"
echo "  http://localhost:3000"
echo ""
echo "Useful commands:"
echo "  ollama ps"
echo "  ollama list"
echo "  ollama run $MODEL"
echo ""
```

Stop script

```shell
adam@Fajita-MacBook-M4:~/Documents/code/local-ai$ cat stop-ai.sh 
#!/bin/bash

set -euo pipefail

MODEL="qwen2.5-coder:3b"
COMPOSE_FILE="docker-compose.yaml"

echo "======================================="
echo " Stopping Local AI Stack"
echo "======================================="

#
# Unload model from RAM
#
echo "[INFO] Stopping model: $MODEL"
ollama stop "$MODEL" > /dev/null 2>&1 || true

#
# Stop Open WebUI
#
echo "[INFO] Stopping Open WebUI..."
docker compose -f "$COMPOSE_FILE" down

#
# Stop Ollama daemon
#
if pgrep -x "ollama" > /dev/null; then
    echo "[INFO] Stopping Ollama..."
    pkill ollama
    echo "[OK] Ollama stopped"
else
    echo "[OK] Ollama already stopped"
fi

echo ""
echo "======================================="
echo " AI Stack Stopped"
echo "======================================="
echo ""
```
