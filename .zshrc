# Created by Zap installer
[ -f "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh" ] && source "${XDG_DATA_HOME:-$HOME/.local/share}/zap/zap.zsh"
plug "zsh-users/zsh-autosuggestions"
plug "zap-zsh/supercharge"
plug "zsh-users/zsh-syntax-highlighting"
plug "zap-zsh/vim"
plug "wintermi/zsh-starship"
plug "MAHcodes/distro-prompt"

# Load and initialise completion system
autoload -Uz compinit
compinit

# mise
eval "$(mise activate zsh)"
