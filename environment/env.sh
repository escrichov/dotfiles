#!/usr/bin/env bash


# PATH AND ENVIRONMENT VARIABLES
export LC_ALL=en_US.UTF-8
export LANG=en_US.UTF-8

# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

# BREW to path
export PATH=/usr/local/bin:/usr/local/sbin:$PATH

# python2 to path
export PATH=$PATH:/usr/local/opt/python@2/bin

# MacText to path
export PATH=$PATH:/usr/local/texbin

# EC2 REGION
export EC2_URL=https://ec2.eu-west-1.amazonaws.com

# Golang environment
export PATH=$PATH:/usr/local/go/bin
export GOPATH=$HOME/All/golang
export PATH=$PATH:$GOPATH/bin

# Java HOME
export JAVA_HOME="$(/usr/libexec/java_home 2> /dev/null)"

# EDITOR
export EDITOR="/usr/local/bin/mate -w"

# Add Keys to SSH Agent
ssh-add -K ~/.ssh/id_rsa &> /dev/null

# Load fuzzy finder (fzf)
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
