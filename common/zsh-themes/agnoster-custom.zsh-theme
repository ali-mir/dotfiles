# agnoster-custom.zsh-theme
# extends agnoster, replacing user@host with a fixed "USER" label

source "${ZSH}/themes/agnoster.zsh-theme"

prompt_context() {
  prompt_segment black default "USER"
}
