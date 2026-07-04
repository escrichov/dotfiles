#!/usr/bin/env bash


# ==============================================
# .osx-system-defaults
# for OS X Mountain Lion (10.8.x)
#
# Commands target the current boot drive
#
# Hannes Juutilainen <hjuutilainen@mac.com>
# ==============================================

# ==============================================
# Date & Time
# ==============================================

# systemsetup requiere que la Terminal tenga Full Disk Access; si no lo tiene
# imprime error y devuelve !=0 (no aborta porque el script no usa set -e).
/usr/sbin/systemsetup -settimezone "Europe/Madrid" || true
/usr/sbin/systemsetup -setnetworktimeserver "time.apple.com" || true
/usr/sbin/systemsetup -setusingnetworktime on || true


# ==============================================
# Set energy preferences
# ==============================================

# Detecta portátil por la presencia de batería interna (el antiguo grep
# "Book" sobre "Model Identifier" ya no funciona: los Mac Apple Silicon usan
# identificadores tipo "Mac14,7" sin "Book").
if pmset -g batt 2>/dev/null | grep -q "InternalBattery"; then
    # Portátil: en batería duerme antes; en corriente no duerme
    pmset -b sleep 15 disksleep 10 displaysleep 5 halfdim 1
    pmset -c sleep 0 disksleep 0 displaysleep 30 halfdim 1
else
    # Sobremesa
    pmset sleep 0 disksleep 0 displaysleep 30 halfdim 1
fi


# ==============================================
# Application layer firewall
# ==============================================
# En macOS moderno el firewall lo gestiona socketfilterfw; escribir el plist
# com.apple.alf directamente ya no surte efecto. Este script corre con sudo.
SOCKETFILTERFW="/usr/libexec/ApplicationFirewall/socketfilterfw"

# Enable firewall
"$SOCKETFILTERFW" --setglobalstate on

# Allow built-in and downloaded signed apps to receive connections
"$SOCKETFILTERFW" --setallowsigned on
"$SOCKETFILTERFW" --setallowsignedapp on

# Enable logging
"$SOCKETFILTERFW" --setloggingmode on

# Enable stealth mode (don't respond to pings / port scans)
"$SOCKETFILTERFW" --setstealthmode on


# NOTA: el brillo automático (com.apple.iokit.AmbientLightSensor) hoy lo
# gestiona CoreBrightness y no es ajustable por 'defaults'; se ha eliminado.


# ==============================================
# Login window
# ==============================================
# Son ajustes a nivel de sistema: hay que escribir en /Library/Preferences,
# no en el dominio de root (que es donde iría con 'defaults write com.apple...'
# al correr con sudo, y no surtiría efecto).

# Display login window as: Name and password
defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool false

# Show shut down etc. buttons
defaults write /Library/Preferences/com.apple.loginwindow PowerOffDisabled -bool false

# Don't show any password hints
defaults write /Library/Preferences/com.apple.loginwindow RetriesUntilHint -int 0

# Don't allow fast user switching
defaults write /Library/Preferences/.GlobalPreferences MultipleSessionEnabled -bool false


# NOTA: las preferencias de teclado (layout Spanish-ISO, key repeat, scroll)
# son del dominio del USUARIO. Este script corre con sudo (dominio de root),
# así que se han movido a osx-user-defaults.sh para que apliquen de verdad.


# ==============================================
# Time Machine
# ==============================================

# Don't offer new disks for backup (dominio de sistema -> ruta completa)
defaults write /Library/Preferences/com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true 2>/dev/null || true


# ==============================================
# Make links to useful apps
# ==============================================
# Solo se crea el enlace si el origen existe (en macOS reciente algunas de
# estas apps se han movido/eliminado -> evita symlinks colgantes).

for app in "Archive Utility" "Directory Utility" "Screen Sharing" "Ticket Viewer"; do
	src="/System/Library/CoreServices/$app.app"
	dst="/Applications/Utilities/$app.app"
	if [ -e "$src" ] && [ ! -e "$dst" ]; then
		ln -s "$src" "$dst" || true
	fi
done

echo "Done. Note that these changes require a restart to take effect."
