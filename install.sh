#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  echo -e \
    "Dotfiles directory already present. Override it? [y/u/q]\n" \
    "   y: yes\n" \
    "   u: update\n" \
    "   q: quit"
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
      echo "Abort..."
      exit 0
      ;;
    esac
  done
fi

git clone https://github.com/0011101100101001/dotfiles.git "$DOTFILES_DIR"

echo
cd "$DOTFILES_DIR"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"
for config_category in editor shell terminal; do
  for config in "$config_category"/*; do

    config=$(basename "$config")
    CONFIG_PATH="$CONFIG_DIR/$config"
    if [[ -d "$CONFIG_PATH" || -f "$CONFIG_PATH" ]]; then
      echo -e \
        "$config already present, which action to perform? [o/b/p]\n" \
        "   o: override\n" \
        "   b: backup\n" \
        "   p: pass"

      while true; do
        read -r answer </dev/tty
        case "$answer" in
        o | O)
          rm -rf "$CONFIG_PATH"
          ln -s "$DOTFILES_DIR/$config_category/$config" "$CONFIG_PATH"
          break
          ;;
        b | B)
          mv "$CONFIG_PATH" "$CONFIG_PATH.bk"
          ln -s "$DOTFILES_DIR/$config_category/$config" "$CONFIG_PATH"
          break
          ;;
        p | P)
          break
          ;;
        esac
      done
      echo
    else
      ln -s "$DOTFILES_DIR/$config_category/$config" "$CONFIG_PATH"
    fi
  done
done

case "$(basename "$SHELL")" in
"bash" | "zsh")
  SHELLRC="$HOME/.$(basename "$SHELL")rc"
  if ! grep "alias.conf" "$SHELLRC"; then
    echo "source $DOTFILES_DIR/shell/alias.conf" >>"$SHELLRC"
    source "$SHELLRC"
  else
    echo "Alias already setup "
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
DOTFILES_BIN_DIR="$HOME/.local/bin"
DOTFILES_BIN="$DOTFILES_BIN_DIR/dotfiles"
if command -v dotfiles >/dev/null; then
  echo -e \
    "Dotfiles binary already installed, override it? [y/n]\n" \
    "   y: yes\n" \
    "   n: no"
  while true; do
    read -r answer </dev/tty
    case "$answer" in
    y | Y)
      rm -f "$DOTFILES_BIN"
      break
      ;;

    n | N)
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

echo "Dotfiles installation done!"
