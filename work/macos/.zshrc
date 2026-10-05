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

# Reset terminal mouse/scroll modes after every ssh session. If tmux on the
# remote dies abruptly (dropped connection, killed tab), it never gets to turn
# off mouse reporting, so the local terminal keeps sending mouse events as
# garbage characters. Turning the modes off here after every ssh fixes that
# without needing a full `reset`.
ssh() {
  command ssh "$@"
  local ret=$?
  if [[ -t 1 ]]; then
    # mouse tracking (1000/1002/1003), SGR/urxvt/xterm mouse encodings
    # (1006/1015/1007), bracketed paste (2004)
    printf '\e[?1000l\e[?1002l\e[?1003l\e[?1006l\e[?1015l\e[?1007l\e[?2004l'
  fi
  return $ret
}

# Manual fix for a terminal stuck in mouse-reporting mode (garbage on scroll)
alias fixterm="printf '\\e[?1000l\\e[?1002l\\e[?1003l\\e[?1006l\\e[?1015l\\e[?1007l\\e[?2004l'"
alias tlc='java -cp $HOME/bin/tla2tools.jar tlc2.TLC'
export PATH="/opt/homebrew/opt/python@3.10/libexec/bin:$PATH"

[[ -s "/Users/ali.mir/.gvm/scripts/gvm" ]] && source "/Users/ali.mir/.gvm/scripts/gvm"
export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Jira/Confluence MCP
[[ -f ~/dev/dotfiles/work/secrets.sh ]] && source ~/dev/dotfiles/work/secrets.sh
export JIRA_URL="https://jira.mongodb.org/"
export CONFLUENCE_URL="https://wiki.corp.mongodb.com/"
