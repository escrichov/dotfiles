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
	# Instala solo las actualizaciones que NO son del sistema operativo
	# (Command Line Tools, Safari, etc.). Las actualizaciones de macOS en si
	# ("macOS Tahoe ...") son una descarga enorme y en Apple Silicon piden
	# autenticacion varias veces (sudo + propietario del volumen para el
	# reinicio), asi que se dejan para instalarlas a mano desde Ajustes.
	local list labels
	list=$(softwareupdate -l 2>&1)
	labels=$(printf '%s\n' "$list" | sed -n 's/^\* Label: //p' | grep -vi '^macOS ')

	if [ -n "$labels" ]; then
		local -a args
		while IFS= read -r label; do
			[ -n "$label" ] && args+=("$label")
		done <<< "$labels"
		echo "macOS: instalando ${#args[@]} actualizacion(es) (requiere sudo):"
		printf '  - %s\n' "${args[@]}"
		sudo softwareupdate -i "${args[@]}"
	else
		echo "macOS: sin actualizaciones (aparte del propio sistema)."
	fi

	# Aviso (sin instalar) si hay una actualizacion del SO pendiente
	if printf '%s\n' "$list" | grep -qi '^\* Label: macOS '; then
		echo "macOS: hay una actualizacion del SISTEMA pendiente. Instalala desde"
		echo "       Ajustes del Sistema > General > Actualizacion de software (reinicia)."
	fi

	update-apps
}

function update() {
	# 'update' solo pide sudo si hay actualizaciones de macOS que instalar
	# (ver update-mac). Todo lo demas (brew, mas, npm, gem, pipx, rustup, omz)
	# se actualiza sin sudo, asi que muchas veces no hara falta contrasena.
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
}
