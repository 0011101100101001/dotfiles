#!/usr/bin/env bash

set -euo pipefail

DOTFILES_DIR="$HOME/.dotfiles"
if [[ -d "$DOTFILES_DIR" ]]; then
  echo "Dotfiles directory already present. Override it? [y/n]"
  while true; do
    read answer
    if [[ $answer == "y" ]]; then
      rm -rf "$DOTFILES_DIR"
      break
    elif [[ $answer == "n" ]]; then
      echo "Abort..."
      exit 0
    fi
  done
fi

git clone https://github.com/0011101100101001/dotfiles.git "$DOTFILES_DIR"

CONFIG_DIR="$HOME/.config"
mkdir -p "$CONFIG_DIR"
for config_category in terminal editor; do
  for config in "$config_category"/*; do
    echo "$config"
    config=$(basename "$config")
    CONFIG_PATH="$CONFIG_DIR/$config"
    echo "$CONFIG_PATH"
    if [[ ! -d "$CONFIG_PATH" ]]; then
      echo here
      rm -rf "$CONFIG_PATH"
    fi
    ln -s "$DOTFILES_DIR/$config_category/$config" "$CONFIG_PATH"
  done
done
