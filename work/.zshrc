# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="agnoster-custom"

plugins=(git)

source $ZSH/oh-my-zsh.sh

alias evgws="ssh ubuntu@ali-mir-2ff.workstations.build.10gen.cc"
export PATH="/opt/homebrew/opt/python@3.10/libexec/bin:$PATH"

[[ -s "/Users/ali.mir/.gvm/scripts/gvm" ]] && source "/Users/ali.mir/.gvm/scripts/gvm"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
