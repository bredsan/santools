#!/bin/bash

# Carregar configurações
source santools.conf

# Função para exibir barra de progresso
show_progress() {
  local -r msg="$1"
  local -r pid="$2"
  local -r delay='0.75'
  local spinstr='\|/-'
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

# Função principal de instalação
install_santools() {
  echo "Instalando santools..."
  # Exemplo de instalação, você pode personalizar conforme necessário
  git clone https://github.com/usuario/santools.git /tmp/santools &
  show_progress "Baixando santools" $!
  sudo mv /tmp/santools/santools /usr/local/bin/santools &
  show_progress "Movendo santools para /usr/local/bin" $!
  echo "santools instalada com sucesso."
}

# Executar
try_santools
install_dependencies
install_santools
