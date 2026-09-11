# Development Environment Files

Includes dot files used for my customized, fast, and relatively minimal development setup built on [Neovim](https://neovim.io/). This project is semi contained with the tools needed through [Mise](https://mise.jdx.dev/) details can be found within the Scripts/bootstrap.sh file on how it is implemented.

# Reasoning

One summer, I bought an older laptop with the goal of installing some Linux distribution and learn more about it. At the time, I was thinking this laptop would be some sort of hacking lab or something, and I had the idea to try to use the Command Line whenever I could. I tried nano, then emacs, but settled on Neovim due to its customizability and documentation availability. After months and months of researching and getting comfortable using it, I started to appreciate and have a better feel for Linux in general. These dotfiles are used for the Neovim config.

# Usage

## Code
```bash
cd
git clone https://github.com/cjn4825/.dotfiles.git
source ~/.dotfiles/scripts/bootstrap.sh
```

## What this does
These dotfiles are designed to work without any dependencies via mise and include all the tools needed, such as npm and python for building the linters and formatters. This script modifies ~/.bashrc and works within devcontainers and normal environments as well of most architectures.

# Folders

## nvim
This includes the bulk and focus of this project, which is all the config files needed for Neovim to work like how I want it to.

## bash
This includes cosmetic changes I've made to the command prompt line, which includes colors that match the theme, username, and hostname on the system, and a status that shows what git branch you're in.

## tmux
This includes config files needed for tmux, the multiplexer I use, so that I can have multiple terminals and windows open, and contains the logic of how it interacts with Neovim for seamless switching.

# Troubleshooting
If you can't use tools provided by mise try sources your bashrc

# Example of Environment

Disclaimer: Your Neovim most likely won't look like this due to the desktop terminal emulator being used. The default terminal in Fedora with a gruvbox theme being used will look close, but mine is customized. In the process of somehow including this within the Dev-Container project...don't know if that's possible or not.

![example picture](nvim/Neovim_example.png)
