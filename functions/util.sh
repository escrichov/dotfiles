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


# update-apps: actualiza las apps de la App Store (mas) y Homebrew.
function update-apps() {
	# Update App Store apps
	mas upgrade

	# Update Homebrew (Cask) & packages
	brew update
	brew upgrade

	# Limpia binarios/descargas viejas: 'brew upgrade' las acumula y la cache
	# puede crecer a decenas de GB (-s = borra tambien la cache de descargas).
	brew cleanup -s
}

# update-macos: instala la actualizacion del propio macOS (separada de 'update'
# porque es una descarga grande, pide autenticacion varias veces y reinicia).
function update-macos() {
	[ -n "$ZSH_VERSION" ] && setopt local_traps
	trap 'echo; echo "update-macos: cancelado."; return 130' INT

	local list labels
	list=$(softwareupdate -l 2>&1)
	labels=$(printf '%s\n' "$list" | sed -n 's/^\* Label: //p' | grep -i '^macOS ')
	if [ -z "$labels" ]; then
		echo "macOS: no hay actualizaciones del sistema."
		return 0
	fi

	local -a args
	while IFS= read -r label; do
		[ -n "$label" ] && args+=("$label")
	done <<< "$labels"

	echo "Se instalara(n) y el equipo SE REINICIARA al terminar:"
	printf '  - %s\n' "${args[@]}"
	printf "¿Continuar? [y/N]: "
	local ans; read -r ans
	case "$ans" in
		[yYsS]) ;;
		*) echo "Cancelado."; return 1 ;;
	esac

	sudo softwareupdate -i "${args[@]}" --restart
}

# update: actualiza todo (macOS no-SO, apps, brew, npm, gem, pipx, rustup, omz).
function update() {
	# Ctrl-C cancela TODO el update (antes solo cortaba el paso en curso y
	# seguia con el siguiente).
	[ -n "$ZSH_VERSION" ] && setopt local_traps
	trap 'echo; echo "update: cancelado."; return 130' INT

	# 1) Actualizaciones de macOS que NO son del sistema operativo (Command
	# Line Tools, Safari...). Las del SO en si ("macOS Tahoe ...") van aparte
	# con 'update-macos'. Solo se pide sudo si hay algo (no-SO) que instalar.
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
	if printf '%s\n' "$list" | grep -qi '^\* Label: macOS '; then
		echo "macOS: hay una actualizacion del SISTEMA pendiente. Instalala con"
		echo "       'update-macos' (reinicia el equipo) o desde Ajustes del Sistema."
	fi

	# 2) App Store (mas) + Homebrew
	update-apps

	# 3) oh-my-zsh (su auto-update automatico esta desactivado en .zshrc
	# para acelerar el arranque, asi que se actualiza aqui a mano)
	command -v omz >/dev/null 2>&1 && omz update

	# (pip/virtualenv ya no se actualizan aqui: el Python de Homebrew es
	# "externally-managed" (PEP 668) y 'pip install' global falla; pip viene
	# con el Python y virtualenv esta en el Brewfile.)

	# Update npm & packages
	npm install -g npm
	npm update -g

	# Update Ruby & gems SOLO si el Ruby activo es reciente (>= 3.2). Con un
	# Ruby viejo/EOL casi todas las gemas fallan y algunas lanzan prompts
	# interactivos que cuelgan el update.
	if ruby -e 'exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2.0"))' 2>/dev/null; then
		# '< /dev/null' para que un conflicto (p.ej. el binario 'rackup' de
		# rack vs rackup) no lance un prompt que cuelgue el update: al no haber
		# stdin, se toma la opcion por defecto (no sobreescribir).
		gem update --system --no-document < /dev/null
		gem update --no-document < /dev/null
	else
		echo "gems: saltado (Ruby $(ruby -v 2>/dev/null | awk '{print $2}') es viejo)."
		echo "      Actualiza con: rbenv install 3.4.10 && rbenv global 3.4.10"
	fi

	# Upgrade all pipx packages (poetry, whisper, ...)
	pipx upgrade-all

	# Update Rust toolchains and rustup itself
	rustup update
	rustup self update
}
