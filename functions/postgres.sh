#!/usr/bin/env bash


export POSTGRES_CONF="${BREW_PATH:-/opt/homebrew}/var/postgresql@16/postgresql.conf"
export POSTGRES_LOGS="${BREW_PATH:-/opt/homebrew}/var/log/postgres.log"
export POSTGRES_LOGS_DIR="${BREW_PATH:-/opt/homebrew}/var/log"

alias postgres_logs='tail -f ${POSTGRES_LOGS}'
alias postgres_logs_clear='echo -n "" > ${POSTGRES_LOGS}'

# Require install npm install pg.log -g
alias postgres_logs_server='pg.log -p 3000 -d ${POSTGRES_LOGS_DIR}'
