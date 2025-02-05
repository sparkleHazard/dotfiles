# Set up the prompt

autoload -U promptinit; promptinit 
#prompt spaceship
eval `starship init zsh`

# source antidote
source ${ZDOTDIR:-~}/.antidote/antidote.zsh

# initialize plugins statically with ${ZDOTDIR:-~}/.zsh_plugins.txt
antidote load

# mise
eval "$(mise activate zsh)"

#SPACESHIP_PROMPT_ADD_NEWLINE=false
#SPACESHIP_PROMPT_SEPARATE_LINE=false
#SPACESHIP_PROMPT_FIRST_PREFIX_SHOW=true
#SPACESHIP_BATTERY_SHOW=false
#SPACESHIP_VI_MODE_SHOW=false
#SPACESHIP_HG_SHOW=false
#SPACESHIP_PACKAGE_SHOW=false
#SPACESHIP_NODE_SHOW=false
#SPACESHIP_RUBY_SHOW=false
#SPACESHIP_ELM_SHOW=false
#SPACESHIP_ELIXIR_SHOW=false
#SPACESHIP_XCODE_SHOW_LOCAL=false
#SPACESHIP_SWIFT_SHOW_LOCAL=false
#SPACESHIP_GOLANG_SHOW=false
#SPACESHIP_PHP_SHOW=false
#SPACESHIP_RUST_SHOW=false
#SPACESHIP_HASKELL_SHOW=false
#SPACESHIP_JULIA_SHOW=false
#SPACESHIP_DOCKER_SHOW=false
#SPACESHIP_DOCKER_CONTEXT_SHOW=false
#SPACESHIP_AWS_SHOW=false
#SPACESHIP_GCLOUD_SHOW=false
#SPACESHIP_DOTNET_SHOW=false
#SPACESHIP_EMBER_SHOW=false
#SPACESHIP_KUBECTL_SHOW=false
#SPACESHIP_KUBECTL_VERSION_SHOW=false
#SPACESHIP_KUBECONTEXT_SHOW=false
#SPACESHIP_GRADLE_SHOW=false
#SPACESHIP_MAVEN_SHOW=false
#SPACESHIP_TERRAFORM_SHOW=false

setopt histignorealldups sharehistory

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# Keep 1000 lines of history within the shell and save it to ~/.zsh_history:
HISTSIZE=1000
SAVEHIST=1000
HISTFILE=~/.zsh_history

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'


#set -o vi

source $HOME/.aliases
source $HOME/.functions

#plugins=(exa)
