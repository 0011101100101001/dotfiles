#!/usr/bin/env bash

set -euo pipefail

RESET="\033[0m"
BOLD="\033[1m"
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
MAGENTA="\033[35m"
CYAN="\033[36m"
WHITE="\033[37m"

# Download and install repository
DOTFILES_DIR="$HOME/.dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e \
    "${BOLD}${WHITE}Dotfiles directory already present. ${YELLOW}Override? ${BLUE}[y/u/q]\n" \
    "   ${BOLD}${BLUE}y: ${RESET}yes\n" \
    "   ${BOLD}${BLUE}u: ${RESET}update\n" \
    "   ${BOLD}${BLUE}q: ${RESET}quit"
  while true; do
    read -r answer </dev/tty
    case "$answer" in
    y | Y)
      rm -rf "$DOTFILES_DIR"
      break
      ;;
    u | U)
      cd "$DOTFILES_DIR"
      git pull
      exit 0
      ;;
    q | Q)
      echo -e "${BOLD}${YELLOW}Abort...${RESET}"
      exit 0
      ;;
    esac
  done
fi
git clone https://github.com/0011101100101001/dotfiles.git "$DOTFILES_DIR"
echo

# Check programs installation, setup config symlinks
cd "$DOTFILES_DIR"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"
for config_category in editor shell terminal; do
  for config in $config_category/*; do
    config=$(basename "$config")
    if [[ "$config" = "alias.conf" ]] || command -v "$config" >/dev/null; then
      CONFIG_PATH_DST="$CONFIG_DIR/$config"
      CONFIG_PATH_SRC="$DOTFILES_DIR/$config_category/$config"
      if [[ -d "$CONFIG_PATH_DST" || -f "$CONFIG_PATH_DST" ]]; then
        echo -e \
          "${BOLD}${MAGENTA}${config^} ${WHITE}already present, which action to perform? ${BLUE}[o/b/p]\n" \
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
    else
      echo -e "${BOLD}${MAGENTA}${config^} ${WHITE}not installed.${RESET}"
    fi
    echo
  done
done

# Setup aliases
case "$(basename "$SHELL")" in
"bash" | "zsh")
  SHELLRC="$HOME/.$(basename "$SHELL")rc"
  if ! grep "alias.conf" "$SHELLRC"; then
    echo "source $DOTFILES_DIR/shell/alias.conf" >>"$SHELLRC"
    source "$SHELLRC"
  else
    echo -e "${BOLD}${MAGENTA}Aliases ${WHITE}already setup.${RESET}"
  fi
  ;;

"fish")
  SHELLRC="$HOME/.$(basename "$SHELL").fish"
  if [[ -f "$HOME/.config/fish/alias.fish" ]]; then
    rm -rf "$HOME/.config/fish/alias.fish"
  fi
  ;;
esac
echo

# Setup fonts
FONT_DIR_DST="$HOME/.local/share/fonts"
mkdir -p "$FONT_DIR_DST"
for font in font/*; do
  FONT_PATH_SRC="$DOTFILES_DIR/$font"
  font=$(basename $font)
  FONT_PATH_DST="$FONT_DIR_DST/$font"
  if [[ -d "$FONT_PATH_DST" ]]; then
    echo -e \
      "${BOLD}${MAGENTA}$(basename $font) ${WHITE}already present, which action to perform? ${BLUE}[o/p]\n" \
      "   ${BOLD}${BLUE}o: ${RESET}override\n" \
      "   ${BOLD}${BLUE}p: ${RESET}pass"

    while true; do
      read -r answer </dev/tty
      case "$answer" in
      o | O)
        rm -rf "$FONT_PATH_DST"
        ln -sv "$FONT_PATH_SRC" "$FONT_PATH_DST"
        break
        ;;
      p | P)
        break
        ;;
      esac
    done
  else
    ln -sv "$FONT_PATH_SRC" "$FONT_PATH_DST"
  fi
  echo
done
fc-cache -v "$FONT_DIR_DST"/* &>/dev/null

# Setup dotfiles binary
DOTFILES_BIN_DIR="$HOME/.local/bin"
DOTFILES_BIN="$DOTFILES_BIN_DIR/dotfiles"
if command -v dotfiles >/dev/null; then
  echo -e \
    "${BOLD}${WHITE}Dotfiles binary already installed. ${YELLOW}Override? ${BLUE}[y/n]\n" \
    "   ${BOLD}${BLUE}y: ${RESET}yes\n" \
    "   ${BOLD}${BLUE}n: ${RESET}no"
  while true; do
    read -r answer </dev/tty
    case "$answer" in
    y | Y)
      rm -f "$DOTFILES_BIN"
      break
      ;;
    n | N)
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

  default)
    echo "Invalid option: $1"
    echo "$USAGE"
    exit 1
    ;;
esac' >"$DOTFILES_BIN"

chmod u+x "$DOTFILES_BIN"

echo -e "${BOLD}${GREEN}Done!${RESET}"
