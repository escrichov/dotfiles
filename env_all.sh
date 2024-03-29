#!/usr/bin/env bash

SCRIPT_DIR=${BASH_SOURCE[0]}
if [ -z "$SCRIPT_DIR" ]; then
	SCRIPT_DIR=$0
fi
DIR=$(cd `dirname $SCRIPT_DIR` && pwd)
BINARIES_DIR=$DIR/bin
FUNCTIONS_DIR=$DIR/functions
ENVIRONMENT_DIR=$DIR/environment
CONFIG_FILE=$DIR/config.sh

# Source config file
[ -f $CONFIG_FILE ] && source $CONFIG_FILE

# Source environment variables
source $ENVIRONMENT_DIR/env.sh
if [ -f $ENVIRONMENT_DIR/env_secret.sh ]; then
	source $ENVIRONMENT_DIR/env_secret.sh
fi

# Source all shell functions
for entry in "$FUNCTIONS_DIR"/*.sh
do
	source "$entry"
done

# Add Dotfiles Binaries to PATH
export PATH=$PATH:$BINARIES_DIR
