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

# Homebrew: no intentar actualizar los casks que se auto-actualizan solos
# (evita los avisos "cannot be upgraded as-is") y oculta los hints de entorno.
export HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS=1
export HOMEBREW_NO_ENV_HINTS=1

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

# NVM (lazy-load): cargar nvm "eager" hacia un auto-use de Node que costaba
# ~1.9s en cada arranque de shell. En su lugar dejamos la version por defecto
# de Node en el PATH al instante, y nvm de verdad solo se carga la primera vez
# que invocas `nvm` (para cambiar de version).
export NVM_DIR="$HOME/.nvm"
NVM_SH="/opt/homebrew/opt/nvm/nvm.sh"; [ -s "$NVM_SH" ] || NVM_SH="$NVM_DIR/nvm.sh"
NVM_COMPLETION="/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"
if [ -d "$NVM_DIR/versions/node" ]; then
    _nvm_default=$(command cat "$NVM_DIR/alias/default" 2>/dev/null)
    case "$_nvm_default" in
        v[0-9]*) _nvm_ver="$_nvm_default" ;;
        *)       _nvm_ver=$(command ls -1 "$NVM_DIR/versions/node" | sort -V | tail -1) ;;
    esac
    if [ -n "$_nvm_ver" ] && [ -d "$NVM_DIR/versions/node/$_nvm_ver/bin" ]; then
        export PATH="$NVM_DIR/versions/node/$_nvm_ver/bin:$PATH"
    fi
    unset _nvm_default _nvm_ver
fi
nvm() {
    unset -f nvm
    [ -s "$NVM_SH" ] && \. "$NVM_SH"                       # carga nvm de verdad
    [ -s "$NVM_COMPLETION" ] && \. "$NVM_COMPLETION"       # y su completion
    nvm "$@"
}

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
if [ -x "$(command -v pyenv)" ]; then
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init -)"
fi
