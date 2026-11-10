#!/usr/bin/env bash

# PostgreSQL de Postgres.app (postgresapp.com). Usa la carpeta de datos var-<N>
# mas alta, asi al pasar a una version mayor nueva no hay que tocar nada.
POSTGRES_VERSION=$(find "$HOME/Library/Application Support/Postgres" -maxdepth 1 -name 'var-*' 2>/dev/null \
    | sed 's/.*var-//' | sort -n | tail -1)
export POSTGRES_VERSION=${POSTGRES_VERSION:-18}
export POSTGRES_DATA="$HOME/Library/Application Support/Postgres/var-$POSTGRES_VERSION"
export POSTGRES_CONF="$POSTGRES_DATA/postgresql.conf"
export POSTGRES_LOGS="$POSTGRES_DATA/postgresql.log"
export POSTGRES_LOGS_DIR="$POSTGRES_DATA"

alias postgres_logs='tail -f "${POSTGRES_LOGS}"'
alias postgres_logs_clear='echo -n "" > "${POSTGRES_LOGS}"'

# Require install npm install pg.log -g
alias postgres_logs_server='pg.log -p 3000 -d "${POSTGRES_LOGS_DIR}"'
