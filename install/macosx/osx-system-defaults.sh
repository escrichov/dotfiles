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

/usr/sbin/systemsetup -settimezone "Europe/Madrid"
/usr/sbin/systemsetup -setnetworktimeserver "time.euro.apple.com"
/usr/sbin/systemsetup -setusingnetworktime on


# ==============================================
# Set energy preferences
# ==============================================

# From <https://github.com/rtrouton/rtrouton_scripts/>
IS_LAPTOP=`/usr/sbin/system_profiler SPHardwareDataType | grep "Model Identifier" | grep "Book"`
if [[ "$IS_LAPTOP" != "" ]]; then
    pmset -b sleep 15 disksleep 10 displaysleep 5 halfdim 1
    pmset -c sleep 0 disksleep 0 displaysleep 30 halfdim 1
else
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


# ==============================================
# Ambient light sensor
# ==============================================

# Display -> Automatically adjust brightness
defaults write com.apple.iokit.AmbientLightSensor "Automatic Display Enabled" -bool true

# Keyboard -> Adjust keyboard brightness in low light
defaults write com.apple.iokit.AmbientLightSensor "Automatic Keyboard Enabled" -bool true
defaults write com.apple.iokit.AmbientLightSensor "Keyboard Dim Time" -int 300


# ==============================================
# Login window
# ==============================================

# Display login window as: Name and password
defaults write com.apple.loginwindow SHOWFULLNAME -bool false

# Show shut down etc. buttons
defaults write com.apple.loginwindow PowerOffDisabled -bool false

# Don't show any password hints
defaults write com.apple.loginwindow RetriesUntilHint -int 0

# Don't allow fast user switching
defaults write .GlobalPreferences MultipleSessionEnabled -bool false

# Hide users with UID under 500
defaults write com.apple.loginwindow Hide500Users -bool YES


# NOTA: las preferencias de teclado (layout Spanish-ISO, key repeat, scroll)
# son del dominio del USUARIO. Este script corre con sudo (dominio de root),
# así que se han movido a osx-user-defaults.sh para que apliquen de verdad.


# ==============================================
# Time Machine
# ==============================================

# Don't offer new disks for backup
defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true


# ==============================================
# Make links to useful apps
# ==============================================

# Archive Utility
if [ ! -L "/Applications/Utilities/Archive Utility.app" ]; then
	ln -s "/System/Library/CoreServices/Archive Utility.app" "/Applications/Utilities/Archive Utility.app"
fi

# Directory Utility
if [ ! -L "/Applications/Utilities/Directory Utility.app" ]; then
	ln -s "/System/Library/CoreServices/Directory Utility.app" "/Applications/Utilities/Directory Utility.app"
fi

# Screen Sharing
if [ ! -L "/Applications/Utilities/Screen Sharing.app" ]; then
	ln -s "/System/Library/CoreServices/Screen Sharing.app" "/Applications/Utilities/Screen Sharing.app"
fi

# Ticket Viewer
if [ ! -L "/Applications/Utilities/Ticket Viewer.app" ]; then
	ln -s "/System/Library/CoreServices/Ticket Viewer.app" "/Applications/Utilities/Ticket Viewer.app"
fi

echo "Done. Note that these changes require a restart to take effect."
