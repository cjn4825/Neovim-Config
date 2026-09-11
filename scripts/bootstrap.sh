#!/usr/bin/env bash

# This script is for bootstrapping environments for neovim use
# Works as a way to package all the tooling I need for
# neovim without needing root access to the system
# as well as any tools pre/post installed when given
# access manually

# main boolean to check if nothing changed or not
CHANGED=false

CONTAINER=false
USERBIN="$HOME/.local/bin"
MISEBIN="$USERBIN/mise"

# bool for checking if in container
VIRT_TYPE="$(systemd-detect-virt --container 2>/dev/null)"
if [ "$VIRT_TYPE" != "none" ] && [ "$VIRT_TYPE" != "wsl" ]; then
    CONTAINER=true
fi

# check if not container to set dotfiles dir
if [ "$CONTAINER" = true ]; then
    DOTFILES="$HOME/dotfiles"
else
    DOTFILES="$HOME/.dotfiles"
fi

# creates ~/.config if not already there
if [ ! -d "$HOME/.config" ]; then
    CHANGED=true
    echo "Creating .config dir..."
    mkdir -p "$HOME/.config"
fi

# creates ~/.local/bin if not already there
if [ ! -d "$HOME/.local/bin" ]; then
    CHANGED=true
    echo "Creating .local/bin dir..."
    mkdir -p "$HOME/.local/bin"
fi

# creates ~/.bashrc.d if not already there
if [ ! -d "$HOME/.bashrc.d" ]; then
    CHANGED=true
    echo "Creating .bashrc.d dir..."
    mkdir -p "$HOME/.bashrc.d"
fi

# function that makes dotfiles link easier
dotlink() {
    local dotLocation="$DOTFILES/$1"
    local confLocation="$HOME/$2"

    if [ ! -d "$confLocation" ] && [ ! -f "$confLocation" ]; then
        CHANGED=true
        echo "Linking [$dotLocation] to [$confLocation]"
        ln -sfn "$dotLocation" "$confLocation"
    fi
}

# Links files downloaded from github to user environment config locations
dotlink "bash/.bashrc.d/prompt.sh" ".bashrc.d/prompt.sh"
dotlink "nvim" ".config/nvim"
dotlink "tmux/.tmux.conf" ".tmux.conf"
dotlink "bin/devup" ".local/bin/devup"
dotlink "bin/devssh" ".local/bin/devssh"

TOOLPATH="
#--- sets user path to .local/bin and adds mise shims
export PATH=\"\$HOME/.local/share/mise/shims:\$HOME/.local/bin:\$PATH\"
#--- end of setting tool path
"

# if user path isn't added already
if ! grep -q "sets user path to" "$HOME/.bashrc"; then

    # adds warning if path is already modified in .bashrc
    if ! grep -q "PATH" "$HOME/.bashrc"; then
        echo "[WARNING] PATH is modified in .bashrc confirm this doesn't effect bootstrapping"
    fi

    CHANGED=true
    echo "Adding user path to .bashrc..."
    echo "$TOOLPATH" >> "$HOME/.bashrc"
fi

# download mise if not already on the system with arch detection
if [ ! -f "$MISEBIN" ]; then
    ARCH="$(uname -m)"
    case "$ARCH" in
        x86_64)  MISE_ARCH="x64" ;;
        aarch64) MISE_ARCH="arm64" ;;
        *) echo "ERROR Unsupported architecture: $ARCH" >&2; exit 1 ;;
    esac

    curl -Lo "$MISEBIN" "https://mise.jdx.dev/mise-latest-linux-$MISE_ARCH"
    chmod +x "$MISEBIN"
fi

#MISEPATH="
##--- sets mise tool shims to be in path
#export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\"
##--- end of mise shims config
#"

# adjust path if inside a container
# commented out for now as i'm thinking of not using contianers
# and just always use mise for in and out
# if [ "$CONTAINER" = true ]; then
    # if ! grep -q "mise tool shims" "$HOME/.bashrc"; then
    #     CHANGED=true
    #     echo "Adding mise tools to PATH"
    #     echo "$MISEPATH" >> "$HOME/.bashrc"
    # fi
# fi

checkmise() {
    local name=$1
    local version=$2
    local tool=$name@$version

    if ! mise where "$tool" >/dev/null 2>&1; then
	$MISEBIN use -g "$tool"
	CHANGED=true
    fi
}

NEOVIM_VERSION="0.12.5"
TMUX_VERSION="3.6b"
RG_VERSION="15.2.0"
FD_VERSION="10.5.0"
FZF_VERSION="0.74.0"
PY_VERSION="3.14.3"
NODE_VERSION="26.8.1"
TS_VERSION="0.27.0"
CLAUDE_VERSION="2.1.261"

checkmise "neovim" "$NEOVIM_VERSION"
checkmise "tmux" "$TMUX_VERSION"
checkmise "ripgrep" "$RG_VERSION"
checkmise "fd" "$FD_VERSION"
checkmise "fzf" "$FZF_VERSION"
checkmise "python" "$PY_VERSION"
checkmise "node" "$NODE_VERSION"
checkmise "tree-sitter" "$TS_VERSION"
checkmise "claude" "$CLAUDE_VERSION"

SOURCE="
# --- start of dotfiles config link ---
if [ -d \"\$HOME/.bashrc.d\" ]; then
    for file in \"\$HOME/.bashrc.d/\"*; do
        [ -r \"\$file\" ] && . \"\$file\"
    done
fi
unset file
# --- end of dotfile config link ---
"

# check if .bashrc.d isn't mentioned in .bashrc
if ! grep -q "start of dotfiles config link" "$HOME/.bashrc" && ! grep -q ".bashrc.d" "$HOME/.bashrc"; then
    CHANGED=true
    echo "Adding .bashrc.d sourcing to .bashrc..."
    echo "$SOURCE" >> "$HOME/.bashrc"
fi

TMUX="
# --- start of devcontainer tmux config ---
# only run in interactive shells
if [[ \$- == *i* ]]; then

    # check if we are already in tmux session
    if command -v tmux >/dev/null 2>&1 && [ -z \"\$TMUX\" ]; then

        # attach if the session exists otherwise create one
        tmux a -t 0 >/dev/null 2>&1 || tmux new-session -s 0 >/dev/null 2>&1

        exit 0
    fi
fi
# --- end of devcontainer tmux config ---
"

# Tmux logic check if host is a container
if [ "$CONTAINER" = true ] && ! grep -q "start of devcontainer tmux config" "$HOME/.bashrc"; then
    CHANGED=true
    echo "Adding tmux sesssion auto attach to .bashrc..."
    echo "$TMUX" >> "$HOME/.bashrc"
fi

# remove any non-tracked mise related binaries
if [[ -n "$("$MISEBIN" ls --prunable 2>/dev/null)" ]]; then
    echo "Removing old tools..."
    "$MISEBIN" prune --tools -y
fi

# output different based on CHANGED value
if [ "$CHANGED" = true ]; then
    echo "Bootstrapping finished"
else
    echo "System is already bootstrapped"
fi
