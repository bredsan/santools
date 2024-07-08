#!/bin/sh

# URL do arquivo de configuração no GitHub
CONFIG_URL="https://raw.githubusercontent.com/bredsan/santools/dev/santools.conf"

# Função para exibir barra de progresso
show_progress() {
  msg="$1"
  pid="$2"
  delay='0.75'
  spinstr='|/-\\'
  i=0

  echo -n "$msg"
  while kill -0 "$pid" 2>/dev/null; do
    i=$(( (i+1) % 4 ))
    printf " [%c]  " "${spinstr:$i:1}"
    sleep "$delay"
    printf "\b\b\b\b\b\b"
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
  for dep in $DEPENDENCIES; do
    if ! check_dependency "$dep"; then
      echo "Instalando dependência: $dep"
      sudo apt-get update -y
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
  . /tmp/santools.conf
}

# Função principal de instalação
install_santools() {
  echo "Instalando santools..."
  if [ -d "/tmp/santools" ]; then
    rm -rf /tmp/santools
  fi
  git clone -b dev https://github.com/bredsan/santools.git /tmp/santools &
  show_progress "Baixando santools" $!
  sudo mv /tmp/santools/santools.sh /usr/local/bin/santools &
  show_progress "Movendo santools para /usr/local/bin" $!
  sudo chmod +x /usr/local/bin/santools
  echo "santools instalada com sucesso."
}

# Função para desinstalar santools
uninstall_santools() {
  echo "Desinstalando santools..."
  sudo rm -f /usr/local/bin/santools
  echo "santools desinstalada com sucesso."
}

# Função para mostrar o uso do script
usage() {
  echo "Uso: $0 [install|uninstall]"
  exit 1
}

# Verifica o argumento passado
case "$1" in
  install)
    try_santools
    fetch_config
    install_dependencies
    install_santools
    ;;
  uninstall)
    uninstall_santools
    ;;
  *)
    usage
    ;;
esac
