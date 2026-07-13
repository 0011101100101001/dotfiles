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

cd "$DOTFILES_DIR"
CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"
for config_category in terminal editor; do
  for config in "$config_category"/*; do
    config=$(basename "$config")
    CONFIG_PATH="$CONFIG_DIR/$config"
    if [[ -d "$CONFIG_PATH" ]]; then
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
  SHELL_RC="$HOME/.$(basename "$SHELL")rc"
  if ! grep "alias.conf" "$SHELL_RC"; then
    echo "source $DOTFILES_DIR/alias.conf" >>"$SHELL_RC"
  fi
  ;;

"fish")
  SHELL_RC="$HOME/.$(basename "$SHELL").fish"
  if [[ -f "$HOME/.config/fish/alias.fish" ]]; then
    rm -rf "$HOME/.config/fish/alias.fish"
  fi
  ;;
esac
