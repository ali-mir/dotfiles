export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster-custom"
plugins=(git)

source $ZSH/oh-my-zsh.sh

export VIRTUAL_ENV_DISABLE_PROMPT=1

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/python/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
