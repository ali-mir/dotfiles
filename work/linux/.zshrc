# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnoster-custom"

plugins=(git virtualenv)

source $ZSH/oh-my-zsh.sh

export EDITOR=vim
export VISUAL=vim

alias activate="source venv/bin/activate"

alias mongobin="cd ~/mongo/bazel-bin/install-devcore/bin/"
alias make_compile_commands="bazel build compiledb"
alias tlc='java -cp $HOME/bin/tla2tools.jar tlc2.TLC'

function build-ninja() {
    /home/ubuntu/mongo/venv/bin/python3 buildscripts/scons.py scons --build-profile=fast ICECC=icecc CCACHE=ccache --ninja
}

function build-ninja-disagg() {
    ./buildscripts/scons.py --build-profile=fast ICECC=icecc CCACHE=ccache --ninja ENABLE_GRPC_BUILD=1
}

function build-ninja-disagg-debug() {
    ./buildscripts/scons.py --build-profile=san ICECC=icecc CCACHE=ccache --ninja ENABLE_GRPC_BUILD=1
}

export PATH="$HOME/bin:$PATH"
export PATH=$PATH:/home/ubuntu/.local/bin
export PATH=$PATH:/home/ubuntu/cli_bin
export PATH=$PATH:/home/ubuntu/mongo/bazel-bin/install-devcore/bin
export PATH=$PATH:/home/ubuntu/mongo/bazel-bin/install-dist-test/bin

# Jira/Confluence MCP
[[ -f ~/dev/dotfiles/work/secrets.sh ]] && source ~/dev/dotfiles/work/secrets.sh
export JIRA_URL="https://jira.mongodb.org/"
export CONFLUENCE_URL="https://wiki.corp.mongodb.com/"

export CARGO_HOME="/home/ubuntu/.ds_toolchain/.cargo"
export RUSTUP_HOME="/home/ubuntu/.ds_toolchain/.rustup"
export PATH="$PATH:/home/ubuntu/.ds_toolchain/yq/bin:/home/ubuntu/.ds_toolchain/jq/bin:/home/ubuntu/.ds_toolchain/buf/bin:/home/ubuntu/.ds_toolchain/minikube/bin:/home/ubuntu/.ds_toolchain/grpcurl/bin:/home/ubuntu/.ds_toolchain/protoc/bin:/home/ubuntu/.ds_toolchain/just/bin:"

# Workstream session management
# Recreate sessions from ~/.workstreams on boot, then attach via session picker
if [[ -z "$TMUX" ]]; then
    if [[ -f ~/.workstreams ]]; then
        while IFS=: read -r name dir flags branch rest; do
            [[ "$name" =~ ^#.*$ || -z "$name" ]] && continue
            dir="${dir/#\~/$HOME}"
            [[ ! -d "$dir" ]] && continue
            if ! tmux has-session -t "=${name}" 2>/dev/null; then
                tmux new-session -d -s "$name" -n zsh -c "$dir"
                if [[ "$flags" == *venv* ]]; then
                    tmux send-keys -t "=${name}:zsh" "source $HOME/mongo/venv/bin/activate" C-m
                    tmux send-keys -t "=${name}:zsh" 'clear' C-m
                fi
                tmux new-window -t "=${name}" -n claude -c "$dir"
                tmux send-keys -t "=${name}:claude" 'claude' C-m
                tmux select-window -t "=${name}:zsh"
            fi
        done < ~/.workstreams
    fi
    ws || true
fi

export PATH="/home/ubuntu/.local/bin:$PATH"
