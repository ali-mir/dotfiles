export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster-custom"
plugins=(git)

source $ZSH/oh-my-zsh.sh

export VIRTUAL_ENV_DISABLE_PROMPT=1

export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="/opt/homebrew/opt/python/bin:$PATH"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/Library/Python/3.9/bin:$PATH"

# workstream session management
# recreate sessions from ~/.workstreams on boot, then attach via session picker
if [[ -z "$TMUX" ]]; then
    if [[ -f ~/.workstreams ]]; then
        while IFS=: read -r name dir; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            dir="${dir/#\~/$HOME}"
            [[ ! -d "$dir" ]] && continue
            if ! tmux has-session -t "=${name}" 2>/dev/null; then
                tmux new-session -d -s "$name" -c "$dir"
            fi
        done < ~/.workstreams
    fi
fi
