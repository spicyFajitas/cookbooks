# Local AI Assistant Setup (MacBook Air M4)

## Recommended Stack

| Component     | Purpose                                  |
| ------------- | ---------------------------------------- |
| Ollama        | Runs local AI models                     |
| Open WebUI    | ChatGPT-style web interface              |
| Qwen2.5-Coder | AI model for coding/OpenShift/Kubernetes |
| Models        | qwen2.5-coder:3b                         |
| Models        | qwen2.5-coder:7b                         |

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
adam@Fajita-MacBook-M4:~$ cat docker-compose.yaml 
services:
  openwebui:
    image: ghcr.io/open-webui/open-webui:main
    ports:
      - "3000:8080"
    volumes:
      - open-webui:/app/backend/data
volumes:
  open-webui:
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

adam@Fajita-MacBook-M4:~$ sudo python3 -m ensurepip --upgrade
adam@Fajita-MacBook-M4:~$ brew install python pipx
adam@Fajita-MacBook-M4:~$ pipx install mlx mlx-lm
adam@Fajita-MacBook-M4:~$ pipx ensurepath
adam@Fajita-MacBook-M4:~$ source ~/.bashrc 
adam@Fajita-MacBook-M4:~$ vim .hf_token
adam@Fajita-MacBook-M4:~$ export HF_TOKEN=$(cat .hf_token)
adam@Fajita-MacBook-M4:~$ echo $HF_TOKEN 
adam@Fajita-MacBook-M4:~$ mlx_lm.chat --model mlx-community/Qwen2.5-Coder-7B-Instruct-4bit
adam@Fajita-MacBook-M4:~$ mlx_lm.chat --model mlx-community/Qwen2.5-Coder-3B-Instruct-4bit
adam@Fajita-MacBook-M4:~$ mlx_lm.chat --model mlx-community/Qwen2.5-Coder-1.5B-Instruct-4bit
```

## Hugging Face Token for Faster Downloads

<https://huggingface.co/settings/tokens>

Create Read Only Token

```shell
vim .hf_token
export HF_TOKEN=$(cat .hf_token)
echo $HF_TOKEN 
```
