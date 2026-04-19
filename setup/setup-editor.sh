# Editor installation script

set -e

source "setup-styling.sh"

VIM_PLUG_PATH="$HOME/.vim/autoload/plug.vim"

# Install vim-plug
if [ ! -f "$VIM_PLUG_PATH" ]; then
    curl -fLo "$VIM_PLUG_PATH" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi