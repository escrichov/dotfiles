#!/usr/bin/env bash


export POSTGRES_CONF="/usr/local/var/postgres/postgresql.conf"
export POSTGRES_LOGS="/usr/local/var/log/postgres.log"
export POSTGRES_LOGS_DIR="/usr/local/var/log"

alias postgres_logs='tail -f ${POSTGRES_LOGS}'
alias postgres_logs_clear='echo -n "" > ${POSTGRES_LOGS}'

# Require install npm install pg.log -g
alias postgres_logs_server='pg.log -p 3000 -d ${POSTGRES_LOGS_DIR}'
