#!/usr/bin/env bash

# PostgreSQL de Postgres.app (postgresapp.com). Si cambias de version mayor en
# la app, actualiza POSTGRES_VERSION (el directorio de datos es var-<version>).
export POSTGRES_VERSION=18
export POSTGRES_DATA="$HOME/Library/Application Support/Postgres/var-$POSTGRES_VERSION"
export POSTGRES_CONF="$POSTGRES_DATA/postgresql.conf"
export POSTGRES_LOGS="$POSTGRES_DATA/postgresql.log"
export POSTGRES_LOGS_DIR="$POSTGRES_DATA"

alias postgres_logs='tail -f "${POSTGRES_LOGS}"'
alias postgres_logs_clear='echo -n "" > "${POSTGRES_LOGS}"'

# Require install npm install pg.log -g
alias postgres_logs_server='pg.log -p 3000 -d "${POSTGRES_LOGS_DIR}"'
