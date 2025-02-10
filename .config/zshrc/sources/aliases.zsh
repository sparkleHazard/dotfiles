alias vim=nvim
alias cat='bat'
alias fzf="fzf --preview 'bat --color=always --style=numbers --line-range=:500 {}'"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='eza'
alias ll='eza -alf'
alias la='eza -A'
alias l='eza -CF'

############################################
# Git aliases
############################################
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'
alias lg='lazygit'

############################################
# Dotfiles git aliases
############################################
alias dotgit='git --git-dir=$HOME/dotfiles/ --work-tree=$HOME'
alias dg='dotgit'
alias dgs='dotgit status'
alias dga='dotgit add'
alias dgc='dotgit commit'
alias dgp='dotgit push'
alias lgd='lazygit --git-dir=$HOME/dotfiles --work-tree=$HOME'

############################################
# SSH aliases
############################################
alias ssh-opnsense='ssh 192.168.1.1'
alias ssh-proxmox-1='ssh root@192.168.1.2'
alias ssh-proxmox-2='ssh root@192.168.1.90'
alias ssh-nginx='ssh 192.168.1.3'
alias ssh-mm='ssh 192.168.1.4'
alias ssh-pihole='ssh 192.168.1.6'
alias ssh-keyserver='ssh 192.168.1.8'
alias ssh-zigbee='ssh 192.168.1.9'
alias ssh-unify='ssh 192.168.1.11'
alias ssh-truenas='ssh 192.168.1.20'

