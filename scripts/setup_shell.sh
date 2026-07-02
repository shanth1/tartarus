#!/bin/bash
set -e
echo "==> configuring zsh and environment..."
apt-get update && apt-get install -y zsh

git clone https://github.com/zsh-users/zsh-autosuggestions /usr/share/zsh-autosuggestions || true
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git /usr/share/zsh-syntax-highlighting || true

cat << 'EOF' > /root/.zshrc
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

autoload -U colors && colors
autoload -Uz vcs_info
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' formats '(%F{green}%b%f%u%c)'
zstyle ':vcs_info:git:*' actionformats '(%F{green}%b%f|%a%u%c)'
precmd() { vcs_info }
setopt PROMPT_SUBST

PROMPT='%F{blue}%n%f%F{white}@%m%f:%F{yellow}%~%f ${vcs_info_msg_0_}%# '

source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias ll='ls -lah'
alias sysupdate='apt update && apt upgrade -y && apt autoremove -y'
EOF

chsh -s /bin/zsh root

echo "==> zsh configured successfully."
