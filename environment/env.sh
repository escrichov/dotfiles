#!/usr/bin/env bash

# DOTFILES_DIR lo exporta env_all.sh de forma fiable (BASH_SOURCE/$0)

# PATH AND ENVIRONMENT VARIABLES
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

# BREW to path
export BREW_PATH=/opt/homebrew
export PATH=$BREW_PATH/bin:$PATH

# Pipx to path
export PIPX_BIN_PATH=$HOME/.local/bin
export PATH=$PATH:$PIPX_BIN_PATH

# EDITOR (TextMate si está; si no, vim)
if command -v mate > /dev/null 2>&1; then
    export EDITOR="mate -w"
else
    export EDITOR="vim"
fi

# Conda
if [ -f "/usr/local/anaconda3/etc/profile.d/conda.sh" ]; then
    source /usr/local/anaconda3/etc/profile.d/conda.sh
fi

# Ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# MacTeX to path
export PATH=$PATH:/Library/TeX/texbin

# Golang environment (el binario go va en $BREW_PATH/bin; solo hace falta GOPATH/bin)
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Gettext
export PATH="$BREW_PATH/opt/gettext/bin:$PATH"

# Java HOME
export JAVA_HOME="$(/usr/libexec/java_home 2> /dev/null)"

# Add Keys to SSH Agent (llavero de Apple; -K quedó obsoleto)
if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add --apple-use-keychain ~/.ssh/id_ed25519 &> /dev/null
fi

# Load fuzzy finder (fzf)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi

# NNN terminal file manager
export NNN_PLUG='p:preview-tui'
export NNN_FIFO=/tmp/nnn.fifo
export PAGER="less -R"

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
[ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -x "$(command -v pyenv)" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
