#!/usr/bin/env bash

set -euo pipefail

RESET="\033[0m"
BOLD="\033[1m"
UNDERLINE="\033[4m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
WHITE="\033[37m"

manage_config_install() {
  CONFIG_PATH_SRC="$1"
  CONFIG_PATH_DST="$2"
  CONFIG_NAME="Config"

  if [[ $# -eq 3 ]]; then
    CONFIG_NAME="$3"
  fi

  if [[ -d "$CONFIG_PATH_DST" || -f "$CONFIG_PATH_DST" ]]; then
    echo -e \
      "${MAGENTA}${CONFIG_NAME} ${BOLD}${WHITE}already present. ${BLUE}[o/b/p]\n" \
      "   ${BOLD}${BLUE}o: ${RESET}override\n" \
      "   ${BOLD}${BLUE}b: ${RESET}backup\n" \
      "   ${BOLD}${BLUE}p: ${RESET}pass"

    while true; do
      read -r answer </dev/tty
      case "$answer" in
      o | O)
        rm -rf "$CONFIG_PATH_DST"
        ln -sv "$CONFIG_PATH_SRC" "$CONFIG_PATH_DST"
        break
        ;;
      b | B)
        mv "$CONFIG_PATH_DST" "$CONFIG_PATH_DST.bk"
        ln -sv "$CONFIG_PATH_SRC" "$CONFIG_PATH_DST"
        break
        ;;
      p | P)
        break
        ;;
      esac
    done
  else
    ln -sv "$CONFIG_PATH_SRC" "$CONFIG_PATH_DST"
  fi
}

echo -e "\n${BOLD}${BLUE}" \
  "   ██████╗  ██████╗ ████████╗███████╗██╗██╗     ███████╗███████╗\n" \
  "   ██╔══██╗██╔═══██╗╚══██╔══╝██╔════╝██║██║     ██╔════╝██╔════╝\n" \
  "   ██║  ██║██║   ██║   ██║   █████╗  ██║██║     █████╗  ███████╗\n" \
  "   ██║  ██║██║   ██║   ██║   ██╔══╝  ██║██║     ██╔══╝  ╚════██║\n" \
  "██╗██████╔╝╚██████╔╝   ██║   ██║     ██║███████╗███████╗███████║\n" \
  "╚═╝╚═════╝  ╚═════╝    ╚═╝   ╚═╝     ╚═╝╚══════╝╚══════╝╚══════╝\n"

# Download and install repository
DOTFILES_DIR="$HOME/.dotfiles"
echo -e "${BOLD}${MAGENTA}${UNDERLINE}Dotfiles${RESET}"
if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e \
    "${MAGENTA}Directory ${BOLD}${WHITE}already present. ${BLUE}[o/u/q]\n" \
    "   ${BOLD}${BLUE}o: ${WHITE}override\n" \
    "   ${BOLD}${BLUE}u: ${WHITE}update\n" \
    "   ${BOLD}${BLUE}q: ${WHITE}quit"
  while true; do
    read -r answer </dev/tty
    case "$answer" in
    o | O)
      rm -rf "$DOTFILES_DIR"
      git clone https://github.com/0011101100101001/dotfiles.git "$DOTFILES_DIR"
      break
      ;;
    u | U)
      echo -en "${BOLD}${GREEN}"
      git -C "$DOTFILES_DIR" pull --ff-only
      echo -en "${RESET}"
      break
      ;;
    q | Q)
      echo -e "${BOLD}${YELLOW}Abort...${RESET}"
      exit 0
      ;;
    esac
  done
else
  git clone https://github.com/0011101100101001/dotfiles.git "$DOTFILES_DIR"
fi
echo

# Check programs installation, setup config symlinks
cd "$DOTFILES_DIR"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"

# Font
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔═╗╔═╗╔╗╔╔╦╗\n" \
  "╠╣ ║ ║║║║ ║ \n" \
  "╚  ╚═╝╝╚╝ ╩\n${RESET}"

readonly FONT_DIR_DST="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR_DST"
for font in font/*; do
  FONT_PATH_SRC="$DOTFILES_DIR/$font"
  font=${font##*/}
  FONT_PATH_DST="$FONT_DIR_DST/$font"
  echo -e "${BOLD}${MAGENTA}${UNDERLINE}$font${RESET}"
  manage_config_install "$FONT_PATH_SRC" "$FONT_PATH_DST"
  echo
done
fc-cache -v "$FONT_DIR_DST"/* &>/dev/null

# TODO: implement shell installation logic
# echo -e "----------------------------------------"
# echo -e "${BOLD}${BLUE}" \
#   "╔═╗╦ ╦╔═╗╦  ╦  \n" \
#   "╚═╗╠═╣║╣ ║  ║  \n" \
#   "╚═╝╩ ╩╚═╝╩═╝╩═╝\n${RESET}"

# Alias
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔═╗╦  ╦╔═╗╔═╗\n" \
  "╠═╣║  ║╠═╣╚═╗\n" \
  "╩ ╩╩═╝╩╩ ╩╚═╝\n${RESET}"

for config in alias/*; do
  config=${config##*/}
  echo -e "${BOLD}${MAGENTA}${UNDERLINE}Alias${RESET}"
  ALIAS_PATH_DST="$CONFIG_DIR/$config"
  ALIAS_PATH_SRC="$DOTFILES_DIR/alias/$config"
  manage_config_install "$ALIAS_PATH_SRC" "$ALIAS_PATH_DST"
done

case ${SHELL##*/} in
"bash" | "zsh")
  SHELLRC="$HOME/.${SHELL##*/}rc"
  if ! grep "alias.conf" "$SHELLRC"; then
    echo "source $DOTFILES_DIR/alias/alias.conf" >>"$SHELLRC"
  else
    echo -e "${BOLD}${MAGENTA}Aliases ${WHITE}already setup.${RESET}"
  fi
  ;;

"fish")
  SHELLRC="$HOME/.${SHELL##*/}.fish"
  if [[ -f "$HOME/.config/fish/alias.fish" ]]; then
    rm -rf "$HOME/.config/fish/alias.fish"
  fi
  ;;
esac
echo

# Terminal
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔╦╗╔═╗╦═╗╔╦╗╦╔╗╔╔═╗╦  \n" \
  " ║ ║╣ ╠╦╝║║║║║║║╠═╣║  \n" \
  " ╩ ╚═╝╩╚═╩ ╩╩╝╚╝╩ ╩╩═╝\n${RESET}"

for config in terminal/*; do
  config=${config##*/}
  echo -e "${BOLD}${MAGENTA}${UNDERLINE}${config^}${RESET}"
  if command -v "$config" >/dev/null; then
    CONFIG_PATH_DST="$CONFIG_DIR/$config"
    CONFIG_PATH_SRC="$DOTFILES_DIR/terminal/$config"
    manage_config_install "$CONFIG_PATH_SRC" "$CONFIG_PATH_DST"
  else
    echo -e "${BOLD}${WHITE}Not installed.${RESET}"
  fi
  echo
done

# Editor
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔═╗╔╦╗╦╔╦╗╔═╗╦═╗\n" \
  "║╣  ║║║ ║ ║ ║╠╦╝\n" \
  "╚═╝═╩╝╩ ╩ ╚═╝╩╚═\n${RESET}"

for config in editor/*; do
  config=${config##*/}
  echo -e "${BOLD}${MAGENTA}${UNDERLINE}${config^}${RESET}"
  if command -v "$config" >/dev/null; then
    CONFIG_PATH_DST="$CONFIG_DIR/$config"
    CONFIG_PATH_SRC="$DOTFILES_DIR/editor/$config"
    manage_config_install "$CONFIG_PATH_SRC" "$CONFIG_PATH_DST"
  else
    echo -e "${BOLD}${WHITE}Not installed.${RESET}"
  fi
  echo
done

# AI
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔═╗╦\n" \
  "╠═╣║\n" \
  "╩ ╩╩\n${RESET}"

AI_CONFIGS_DIR_DST=(
  "$HOME/.claude"
  "$HOME/.codex"
  "$HOME/.config/opencode"
)

i=0
for config_dir in ai/*; do
  program=${config_dir##*/}
  echo -e "${BOLD}${MAGENTA}${UNDERLINE}${program^}${RESET}"
  if command -v $program &>/dev/null; then
    for config_file in $config_dir/*; do
      AI_CONFIGS_PATH_DST="${AI_CONFIGS_DIR_DST[$i]}/${config_file##*/}"
      AI_CONFIGS_PATH_SRC="$DOTFILES_DIR/$config_file"
      manage_config_install "$AI_CONFIGS_PATH_SRC" "$AI_CONFIGS_PATH_DST" "${config_file##*/}"
      echo
    done
  else
    echo -e "${BOLD}${WHITE}Not installed.${RESET}"
  fi
  ((++i))
done

# TODO: implement boot installation logic
# echo -e "----------------------------------------"
# echo -e "${BOLD}${BLUE}" \
#   "╔╗ ╔═╗╔═╗╔╦╗\n" \
#   "╠╩╗║ ║║ ║ ║ \n" \
#   "╚═╝╚═╝╚═╝ ╩${RESET}"

# Setup dotfiles binary
echo -e "----------------------------------------"
echo -e "${BOLD}${BLUE}" \
  "╔╗ ╦╔╗╔╔═╗╦═╗╦ ╦\n" \
  "╠╩╗║║║║╠═╣╠╦╝╚╦╝\n" \
  "╚═╝╩╝╚╝╩ ╩╩╚═ ╩\n${RESET}"

DOTFILES_BIN_DIR="$HOME/.local/bin"
DOTFILES_BIN="$DOTFILES_BIN_DIR/dotfiles"
if command -v dotfiles >/dev/null; then
  echo -e \
    "${BOLD}${WHITE}Dotfiles binary already installed. ${BLUE}[o/p]\n" \
    "   ${BOLD}${BLUE}o: ${RESET}override\n" \
    "   ${BOLD}${BLUE}p: ${RESET}pass"
  while true; do
    read -r answer </dev/tty
    case "$answer" in
    o | O)
      rm -f "$DOTFILES_BIN"
      break
      ;;
    p | P)
      echo -e "${BOLD}${GREEN}Done!${RESET}"
      exit 0
      ;;
    esac
  done
fi

echo -e "Installing dotfiles binary...\n"
mkdir -p "$DOTFILES_BIN_DIR"
echo \
  '#!/bin/bash

USAGE=\
"Usage: dotfiles [option]
  i: install
  u: update
"

if [[ $# -ne 1 ]]; then
  echo "$USAGE"
  exit 1
fi

DOTFILES_DIR="$HOME/.dotfiles"
case "$1" in
  i)
    curl -fsSL https://raw.githubusercontent.com/0011101100101001/dotfiles/main/install.sh | bash 
    ;;

  u)
    cd "$DOTFILES_DIR"
    git pull
    ;;

  *)
    echo "Invalid option: $1"
    echo "$USAGE"
    exit 1
    ;;
esac' >"$DOTFILES_BIN"
chmod u+x "$DOTFILES_BIN"

echo -e "\n${BOLD}${GREEN}Done!${RESET}"
