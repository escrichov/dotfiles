#!/usr/bin/env bash

# cleanup: libera espacio en disco borrando SOLO cachés regenerables (Homebrew,
# npm/yarn/pnpm/pip, CocoaPods, Xcode DerivedData, Gradle, nvm, Docker). No toca
# datos de usuario ni la Papelera. Reporta cuánto se ha liberado.
function cleanup {
	local before after freed
	before=$(df -k / | awk 'NR==2{print $4}')
	echo "== Liberando espacio (solo cachés regenerables) =="

	if command -v brew >/dev/null 2>&1; then
		echo "→ Homebrew"; brew cleanup -s --prune=all >/dev/null 2>&1
	fi
	if command -v npm >/dev/null 2>&1; then
		echo "→ npm"; npm cache clean --force >/dev/null 2>&1
	fi
	command -v yarn >/dev/null 2>&1 && { echo "→ yarn"; yarn cache clean >/dev/null 2>&1; }
	command -v pnpm >/dev/null 2>&1 && { echo "→ pnpm"; pnpm store prune >/dev/null 2>&1; }
	command -v pip3 >/dev/null 2>&1 && { echo "→ pip"; pip3 cache purge >/dev/null 2>&1; }
	command -v pod  >/dev/null 2>&1 && { echo "→ CocoaPods"; pod cache clean --all >/dev/null 2>&1; }

	[ -d "$HOME/.nvm/.cache" ]        && { echo "→ nvm cache";        rm -rf "$HOME/.nvm/.cache/"* 2>/dev/null; }
	[ -d "$HOME/.gradle/caches" ]     && { echo "→ Gradle cache";     rm -rf "$HOME/.gradle/caches/"* 2>/dev/null; }
	[ -d "$HOME/Library/Developer/Xcode/DerivedData" ] && { echo "→ Xcode DerivedData"; rm -rf "$HOME/Library/Developer/Xcode/DerivedData/"* 2>/dev/null; }

	if command -v xcrun >/dev/null 2>&1; then
		echo "→ Simuladores de OS no instalados"; xcrun simctl delete unavailable >/dev/null 2>&1
	fi
	if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
		echo "→ Docker (imágenes colgantes + build cache)"
		docker image prune -f >/dev/null 2>&1
		docker builder prune -f >/dev/null 2>&1
	fi

	after=$(df -k / | awk 'NR==2{print $4}')
	freed=$(( (after - before) / 1024 ))
	echo
	echo "Liberado: ~${freed} MB.  Espacio libre ahora: $(df -h / | awk 'NR==2{print $4}')"

	# Aviso de la Papelera (no se vacía sola por seguridad)
	local trash
	trash=$(du -sh "$HOME/.Trash" 2>/dev/null | awk '{print $1}')
	[ -n "$trash" ] && echo "Papelera: $trash (vacíala tú si quieres: rm -rf ~/.Trash/* o desde Finder)"
}
