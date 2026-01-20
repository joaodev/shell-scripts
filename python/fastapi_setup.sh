#!/usr/bin/env bash

################################################################################
# FastAPI Setup Script
# Description: Sets up a FastAPI project with virtualenv, folder structure, and logging
# Author: João Augusto Bonfante
# GitHub: https://github.com/joaodev
# Date: January 2026
################################################################################

set -euo pipefail
IFS=$'\n\t'

# Defaults
PROJECT_PARENT_DEFAULT="$HOME/Documentos/shell-scripts/python"
PROJECT_NAME=""
PROJECT_PARENT="$PROJECT_PARENT_DEFAULT"
PROJECT_DIR=""
LOG_FILE="${HOME}/.local/state/shell-scripts/fastapi_setup.log"
AUTO_YES=false

timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '%s %s\n' "$(timestamp)" "$*" | tee -a "$LOG_FILE"; }
command_exists() { command -v "$1" >/dev/null 2>&1; }

confirm() {
  if [ "$AUTO_YES" = true ]; then
    log "Auto-approve enabled — skipping confirmation: $1"
    return 0
  fi
  local resp
  read -r -p "$1 [y/N]: " resp
  case "$resp" in
    [yY]|[yY][eE][sS]) return 0 ;;
    *) return 1 ;;
  esac
}

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  -n, --name NAME       Project name (default: fastapi_project)
  -p, --path PATH       Parent directory where project will be created (default: $PROJECT_PARENT_DEFAULT)
  -l, --logfile FILE    Log file (default: $LOG_FILE)
  -y, --yes             Assume yes for all prompts (non-interactive)
  -h, --help            Show this help
EOF
}

log "=== FastAPI Setup Script ==="

# Parse args
while [ "$#" -gt 0 ]; do
  case "$1" in
    -n|--name) PROJECT_NAME="$2"; shift 2 ;;
    -p|--path) PROJECT_PARENT="$2"; shift 2 ;;
    -l|--logfile) LOG_FILE="$2"; shift 2 ;;
    -y|--yes) AUTO_YES=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; break ;;
    -*) log "Opção desconhecida: $1"; usage; exit 1 ;;
    *) break ;;
  esac
done

: "${PROJECT_NAME:=fastapi_project}"
: "${PROJECT_PARENT:=$PROJECT_PARENT_DEFAULT}"

PROJECT_DIR="$PROJECT_PARENT/$PROJECT_NAME"

log "Parâmetros: project='$PROJECT_NAME' path='$PROJECT_PARENT' logfile='$LOG_FILE' auto-yes='$AUTO_YES'"
if ! confirm "Criar projeto '$PROJECT_NAME' em '$PROJECT_DIR'?"; then
  log "Operação cancelada pelo usuário"
  exit 0
fi

log "Criando diretório $PROJECT_DIR..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

log "Criando virtualenv e ativando..."
python3 -m venv venv
# shellcheck disable=SC1091
source venv/bin/activate

log "Atualizando pip..."
pip install --upgrade pip

log "Instalando dependências: fastapi, uvicorn, python-dotenv, pydantic"
pip install fastapi uvicorn python-dotenv pydantic

log "Criando estrutura de pastas e arquivos..."
mkdir -p app tests

log "Criando app/main.py"
cat > app/main.py << 'EOF'
from fastapi import FastAPI
from pydantic import BaseModel

app = FastAPI(title="My FastAPI App", version="1.0.0")

class Item(BaseModel):
    name: str
    price: float
    description: str = None

@app.get("/")
def read_root():
    return {"message": "Welcome to FastAPI"}

@app.post("/items/")
def create_item(item: Item):
    return {"item": item, "status": "created"}
EOF

log "Generating requirements.txt"
pip freeze > requirements.txt

log "Creating .env"
cat > .env << 'EOF'
DATABASE_URL=sqlite:///./test.db
DEBUG=True
EOF

log "Creating .gitignore"
cat > .gitignore << 'EOF'
venv/
__pycache__/
*.pyc
.env
.DS_Store
EOF

log "✓ FastAPI project created at: $PROJECT_DIR"
log "To start: cd $PROJECT_DIR && source venv/bin/activate && uvicorn app.main:app --reload" 
