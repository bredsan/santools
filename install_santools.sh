#!/bin/bash

# URL do arquivo de configuração no GitHub
CONFIG_URL="https://raw.githubusercontent.com/bredsan/santools/dev/santools.conf"

# Função para exibir barra de progresso
show_progress() {
  local -r msg="$1"
  local -r pid="$2"
  local -r delay='0.75'
  local spinstr='|/-\\'
  local temp

  echo -n "$msg"
  while true; do
    temp="${spinstr#?}"
    printf " [%c]  " "$spinstr"
    spinstr=$temp${spinstr%"$temp"}
    sleep "$delay"
    printf "\b\b\b\b\b\b"
    if ! kill -0 "$pid" 2>/dev/null; then
      break
    fi
  done
  printf "    \b\b\b\b"
  echo ""
}

# Função para verificar se uma dependência está instalada
check_dependency() {
  command -v "$1" >/dev/null 2>&1
}

# Função para instalar dependências
install_dependencies() {
  for dep in "${DEPENDENCIES[@]}"; do
    if ! check_dependency "$dep"; then
      echo "Instalando dependência: $dep"
      sudo apt-get install -y "$dep" &
      show_progress "Instalando $dep" $!
    else
      echo "Dependência já instalada: $dep"
    fi
  done
}

# Função para verificar se santools está instalada
try_santools() {
  if check_dependency "santools"; then
    echo "santools já está instalada."
    exit 0
  fi
}

# Função para baixar o arquivo de configuração
fetch_config() {
  echo "Baixando arquivo de configuração..."
  curl -fsSL "$CONFIG_URL" -o /tmp/santools.conf
  source /tmp/santools.conf
}

# Função principal de instalação
install_santools() {
  echo "Instalando santools..."
  # Clonar a branch dev do repositório
  git clone -b dev https://github.com/bredsan/santools.git /tmp/santools &
  show_progress "Baixando santools" $!
  sudo mv /tmp/santools/santools /usr/local/bin/santools &
  show_progress "Movendo santools para /usr/local/bin" $!
  echo "santools instalada com sucesso."
}

# Executar
try_santools
fetch_config
install_dependencies
install_santools
