#!/usr/bin/env bash

# DOTFILES DIRECTORY
FILENAME=$_
export DOTFILES_DIR=$( dirname $(dirname $FILENAME))

# PATH AND ENVIRONMENT VARIABLES
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

# BREW to path
export BREW_PATH=/opt/homebrew
export PATH=$BREW_PATH/bin:$PATH

# EDITOR
export EDITOR="$BREW_PATH/bin/mate -w"

# Conda
if [ -f "/usr/local/anaconda3/etc/profile.d/conda.sh" ]; then
    source /usr/local/anaconda3/etc/profile.d/conda.sh
fi

# Ruby
if which rbenv > /dev/null; then eval "$(rbenv init -)"; fi

# MacText to path
export PATH=$PATH:$BREW_PATH/texbin

# Golang environment
export PATH=$PATH:$BREW_PATH/go/bin
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Gettext
export PATH="/usr/local/opt/gettext/bin:$PATH"

# Java HOME
export JAVA_HOME="$(/usr/libexec/java_home 2> /dev/null)"

# Add Keys to SSH Agent
if [ -f ~/.ssh/id_ed25519 ]; then
    ssh-add -K ~/.ssh/id_ed25519 &> /dev/null
fi

# Load fuzzy finder (fzf)
if [ -f ~/.fzf.zsh ]; then
    source ~/.fzf.zsh
fi