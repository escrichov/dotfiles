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


# _update-brew: Homebrew (formulas + casks) y limpieza de la cache.
function _update-brew() {
	local rc=0
	brew update || rc=1
	brew upgrade || rc=1

	# Limpia binarios/descargas: 'brew upgrade' las acumula y la cache puede
	# crecer a decenas de GB. '-s' borra versiones viejas; '--prune=all' borra
	# TODAS las descargas (son regenerables: brew las re-baja si hiciera falta),
	# asi la cache no vuelve a inflarse tras actualizar instaladores gordos.
	brew cleanup -s --prune=all || rc=1
	return $rc
}

# update-apps: actualiza Homebrew y las apps de la App Store (mas).
# Brew va primero: 'mas' a veces se queda colgado con la App Store y asi
# brew ya esta hecho aunque haya que cortarlo.
function update-apps() {
	local rc=0
	_update-brew || rc=1
	mas upgrade || rc=1
	return $rc
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

# _update-macos-extras: actualizaciones de macOS que NO son del sistema
# operativo (Command Line Tools, Safari...). Las del SO en si ("macOS Tahoe
# ...") van aparte con 'update-macos'.
function _update-macos-extras() {
	local list labels
	list=$(softwareupdate -l 2>&1)
	labels=$(printf '%s\n' "$list" | sed -n 's/^\* Label: //p' | grep -vi '^macOS ')
	local rc=0
	if [ -n "$labels" ]; then
		local -a args
		while IFS= read -r label; do
			[ -n "$label" ] && args+=("$label")
		done <<< "$labels"
		echo "macOS: instalando ${#args[@]} actualizacion(es):"
		printf '  - %s\n' "${args[@]}"
		sudo softwareupdate -i "${args[@]}" || rc=1
	else
		echo "macOS: sin actualizaciones (aparte del propio sistema)."
	fi
	if printf '%s\n' "$list" | grep -qi '^\* Label: macOS '; then
		echo "macOS: hay una actualizacion del SISTEMA pendiente. Instalala con"
		echo "       'update-macos' (reinicia el equipo) o desde Ajustes del Sistema."
	fi
	return $rc
}

# _update-gems: Ruby & gems SOLO si el Ruby activo es reciente (>= 3.2). Con
# un Ruby viejo/EOL casi todas las gemas fallan y algunas lanzan prompts
# interactivos que cuelgan el update.
function _update-gems() {
	if ! ruby -e 'exit(Gem::Version.new(RUBY_VERSION) >= Gem::Version.new("3.2.0"))' 2>/dev/null; then
		echo "gems: saltado (Ruby $(ruby -v 2>/dev/null | awk '{print $2}') es viejo)."
		echo "      Actualiza con: rbenv install 3.4.10 && rbenv global 3.4.10"
		return 0
	fi
	local rc=0
	# '< /dev/null' para que un conflicto (p.ej. el binario 'rackup' de
	# rack vs rackup) no lance un prompt que cuelgue el update: al no haber
	# stdin, se toma la opcion por defecto (no sobreescribir).
	gem update --system --no-document < /dev/null || rc=1

	# Se actualizan las gemas explicitamente EXCLUYENDO las "congeladas":
	# aquellas cuya ultima version exige un Ruby mas nuevo del instalado y
	# que solo viven como dependencia fijada. Ej.: 'xdg' 10.x pide Ruby
	# >= 4.0 y aqui solo la usa tmuxinator ('~> 2.2'); un 'gem update' pelado
	# la intentaba cada vez y soltaba un ERROR inofensivo pero molesto.
	local _gem_hold="xdg"
	local -a _gems; local _g
	while IFS= read -r _g; do
		[ -n "$_g" ] && [ "$_g" != "$_gem_hold" ] && _gems+=("$_g")
	done < <(gem list --no-versions 2>/dev/null)
	if [ ${#_gems[@]} -gt 0 ]; then
		gem update --no-document "${_gems[@]}" < /dev/null || rc=1
	fi
	return $rc
}

# update: actualiza todo (macOS no-SO, brew, App Store, omz, npm, gem, pipx,
# rustup). Si un paso falla sigue con el resto y al final dice cuales fallaron.
function update() {
	# Ctrl-C cancela TODO el update (no solo el paso en curso).
	[ -n "$ZSH_VERSION" ] && setopt local_traps local_options no_monitor no_notify
	local _cancel=
	local -a _fails
	trap '_cancel=1; return 130' INT

	# Pide la contraseña de sudo UNA vez al principio y la mantiene viva en
	# segundo plano (sudo caduca a los 5 min), para que softwareupdate o mas
	# no se queden esperando a mitad del update.
	local _sudo_pid=
	if sudo -v; then
		( while sudo -n true 2>/dev/null; do
			sleep 50
			kill -0 $$ 2>/dev/null || exit
		  done ) &
		_sudo_pid=$!
	fi

	# _paso NOMBRE CMD...: ejecuta un paso; si falla lo apunta y sigue.
	# Devuelve 130 solo si se ha cancelado con Ctrl-C.
	_paso() {
		local name=$1; shift
		printf '\n\033[1;34m==> %s\033[0m\n' "$name"
		"$@"
		local rc=$?
		{ [ -n "$_cancel" ] || [ $rc -eq 130 ]; } && return 130
		[ $rc -ne 0 ] && _fails+=("$name")
		return 0
	}

	{
		_paso "macOS" _update-macos-extras &&
		_paso "Homebrew" _update-brew &&
		_paso "App Store" mas upgrade &&
		{ ! command -v omz >/dev/null 2>&1 || _paso "oh-my-zsh" omz update; } &&
		# (pip/virtualenv no se actualizan aqui: el Python de Homebrew es
		# "externally-managed" (PEP 668) y 'pip install' global falla.)
		_paso "npm" sh -c 'npm install -g npm && npm update -g' &&
		_paso "gems" _update-gems &&
		_paso "pipx" pipx upgrade-all &&
		_paso "rustup" sh -c 'rustup update && rustup self update'
	} || _cancel=1

	# Casks que se actualizan solos (no los toca brew por
	# HOMEBREW_NO_UPGRADE_AUTO_UPDATES_CASKS): solo informa de los pendientes.
	if [ -z "$_cancel" ]; then
		local _greedy
		_greedy=$(brew outdated --cask --greedy --quiet 2>/dev/null)
		if [ -n "$_greedy" ]; then
			printf '\nCasks que se actualizan solos y van por detras (abrelos o\n'
			printf "'brew upgrade --cask --greedy <nombre>'):\n"
			printf '%s\n' "$_greedy" | sed 's/^/  - /'
		fi
	fi

	if [ -n "$_sudo_pid" ]; then
		pkill -P "$_sudo_pid" 2>/dev/null
		kill "$_sudo_pid" 2>/dev/null
	fi
	unfunction _paso 2>/dev/null

	if [ -n "$_cancel" ]; then
		echo; echo "update: cancelado."
		return 130
	elif [ ${#_fails[@]} -gt 0 ]; then
		printf '\n\033[1;31mupdate: fallaron %d paso(s): %s\033[0m\n' ${#_fails[@]} "${_fails[*]}"
		return 1
	fi
	printf '\n\033[1;32mupdate: todo actualizado.\033[0m\n'
}
