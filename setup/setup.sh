#!/usr/bin/env bash

set -e

source "setup-styling.sh"
source "setup-editor.sh"

DOTFILES_DIR="$HOME/dotfiles"

echo -e "${BOLD}${ITALIC}${MAGENTA}Dotfiles${RESET}"
if [ -d "$DOTFILES_DIR" ]; then
    echo -en "${BOLD}${BLUE}Setup: "
    echo -e "${BOLD}${YELLOW}${DOTFILES_DIR}${WHITE} already exist."
    echo -e "Remove it or abord setup process? [y/n]${RESET}"

    while true; do
        read answer
        if [[ "$answer" == "y" ]]; then
            rm -rf $DOTFILES_DIR
            break
        elif [[ "$answer" == "n" ]]; then
            echo -e "${BOLD}${BLUE}Setup:${WHITE} abording...${RESET}"
            exit 0
        fi
    done
fi

mkdir -p "$DOTFILES_DIR"


# Create symlink
