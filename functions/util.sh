#!/usr/bin/env bash


# tar alias
function tar-compress {
	local DIR=$1
	tar -zcf "$DIR.tar.gz" "$DIR"
}

alias tar-decompress='tar -zxf'

function search-content {
    local DIR=$1
    local PATTERN=$2

    if [ -z "$DIR" ] || [ -z "$PATTERN" ];then
        echo "Usage: $0 [directory] [pattern]"
        return 1
    fi

    grep -R "$PATTERN" "$DIR" 2> /dev/null
}

function search-files {
    local DIR=$1
    local PATTERN=$2

    if [ -z "$DIR" ] || [ -z "$PATTERN" ];then
        echo "Usage: $0 [directory] [pattern]"
        return 1
    fi

    find "$DIR" -iname "$PATTERN" 2> /dev/null
}

function remux {
    local INPUT=$1
    local OUTPUT=$2

    if [ -z "$INPUT" ] || [ -z "$OUTPUT" ];then
        echo "Usage: $0 [input.avi] [output.mp4]"
        return 1
    fi

    ffmpeg -i "$INPUT" -c:v copy -c:a copy "$OUTPUT"
}

# Coloring man pages
function man() {
    LESS_TERMCAP_mb=$'\e'"[1;31m" \
    LESS_TERMCAP_md=$'\e'"[1;31m" \
    LESS_TERMCAP_me=$'\e'"[0m" \
    LESS_TERMCAP_se=$'\e'"[0m" \
    LESS_TERMCAP_so=$'\e'"[1;44;33m" \
    LESS_TERMCAP_ue=$'\e'"[0m" \
    LESS_TERMCAP_us=$'\e'"[1;32m" \
    command man "$@"
}

function reload() {
    source $DOTFILES_DIR/env_all.sh
}


function update-apps() {
	# Update App Store apps
	mas upgrade

	# Update Homebrew (Cask) & packages
	brew update
	brew upgrade
}

function update-mac() {
	# Update Mac OS X
	sudo softwareupdate -i -a

	update-apps
}

function update() {
	# Pide la contrasena de sudo UNA sola vez al principio y la mantiene viva
	# en segundo plano mientras dura el update, para no volver a preguntar a
	# mitad. Lo unico que necesita sudo es 'softwareupdate'; el resto (brew,
	# mas, npm, gem, pipx, rustup, omz) se actualiza sin sudo.
	if ! sudo -v; then
		echo "update: se necesita sudo para softwareupdate" >&2
		return 1
	fi
	# Keep-alive: refresca el timestamp de sudo cada 60s hasta que update acabe
	# (o hasta que se cierre esta shell).
	while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done &
	local _sudo_keepalive=$!

	update-mac

	# Update oh-my-zsh (su auto-update automatico esta desactivado en .zshrc
	# para acelerar el arranque, asi que se actualiza aqui a mano)
	command -v omz >/dev/null 2>&1 && omz update

	# Update pip & virtualenv
	gpip install --upgrade pip virtualenv

	# Update npm & packages
	npm install -g npm
	npm update -g

	# Update Ruby & gems
	gem update --system
	gem update

	# Upgrade all pipx packages (poetry, whisper, ...)
	pipx upgrade-all

	# Update Rust toolchains and rustup itself
	rustup update
	rustup self update

	# Parar el keep-alive de sudo
	kill "$_sudo_keepalive" 2>/dev/null
}
