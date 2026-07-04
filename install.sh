#!/usr/bin/env zsh

set -e

# zsh no puebla BASH_SOURCE; ${0:A:h} = ruta absoluta del dir de este script
DOTFILES_DIRECTORY="${0:A:h}"
INSTALL_DIR=$DOTFILES_DIRECTORY/install
CONFIG_FILE=$DOTFILES_DIRECTORY/config.sh
ALL_ENVIRONMENT_FILE=$DOTFILES_DIRECTORY/env_all.sh

GIT_CONFIG_CREDENTIALS_FILE=$DOTFILES_DIRECTORY/dots/.gitconfig.credentials
GIT_CONFIG_CRENDENTIAL_METHOD=osxkeychain

BASHRC=~/.zshrc
OHMYZSHDIRECTORY=$HOME/.oh-my-zsh

TITLE_MESSAGE="Escrichov Dotfiles"
COLOUR_STEP=green
COLOUR_TITLE=yellow
COLOUR_VARIABLE=yellow


function _term() {
    echo-colour red "Installation script stopped"
    exit 1
}

function print_title ()
{
    echo-colour $COLOUR_TITLE "$TITLE_MESSAGE"
}

function print_variable ()
{
    echo-colour $COLOUR_VARIABLE "$1: $2"
}

function print_step ()
{
    echo-colour $COLOUR_STEP "* $1"
}

function print_error ()
{
    echo-colour red "$1"
    _term
}

# Source all environment
source $ALL_ENVIRONMENT_FILE

# Catch signals to exit correctly
trap _term SIGTERM
trap _term INT

# Print dotfiles title
print_title

# Ask for sudo only first
print_step "Ask for sudo password upfront"
sudo -v # ask for sudo upfront

# Create configuration file with Name, Email
if [ ! -f "$CONFIG_FILE" ]
then
    print_step "Creating configuration file"
    echo -n "Enter full name: "
    read NAME

    echo -n "Enter email: "
    read EMAIL

    cat <<EOT >> $CONFIG_FILE
#!/usr/bin/env bash

NAME="$NAME"
EMAIL="$EMAIL"
EOT
echo "Config file saved in $CONFIG_FILE"
else
    source $CONFIG_FILE
fi

# Install or Update Brew
(
    BREW_BIN=$BREW_PATH/bin/brew

    if [ ! -f $BREW_BIN ]; then
        print_step "Installing Brew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    else
        print_step "Updating Brew"

        brew update
        brew upgrade
    fi

    # Disable analytics
    brew analytics off
)

# Configure MacOS X Preferences that required sudo permissions
(
    cd $INSTALL_DIR/macosx

    print_step "Xcode command line developer tools"
    ./xcode.sh

    print_step "Installing system Preferences"
    sudo ./osx-system-defaults.sh
)

# Install Brew packages
(
    cd $INSTALL_DIR/brew
    print_step "Installing Brew packages and applications"
    brew bundle
)

# Install dotfiles
(
    print_step "Installing dotfiles"
    stow --target=$HOME --dir=$DOTFILES_DIRECTORY dots
)

# Install SwiftBar plugins
# NOTE: copiamos el archivo (no symlink). Un symlink en esta carpeta hace que
# algunas herramientas dejen directorios temporales vacíos al escribir sobre él.
# swiftbar-plugins/ está en .gitignore (contiene IPs/MACs del homelab), así que
# en un clon nuevo puede no existir: si falta, se salta sin romper la instalación.
(
    print_step "Installing SwiftBar plugins"
    SWIFTBAR_PLUGINS_DIR="$HOME/Library/Application Support/SwiftBar/Plugins"
    SWIFTBAR_PLUGIN_SRC="$DOTFILES_DIRECTORY/swiftbar-plugins/homelab.py"
    if [ -f "$SWIFTBAR_PLUGIN_SRC" ]; then
        mkdir -p "$SWIFTBAR_PLUGINS_DIR"
        cp "$SWIFTBAR_PLUGIN_SRC" "$SWIFTBAR_PLUGINS_DIR/homelab.5s.py"
        chmod +x "$SWIFTBAR_PLUGINS_DIR/homelab.5s.py"
    else
        print_step "SwiftBar plugin not found (swiftbar-plugins/ gitignored) - skipping"
    fi
)

# NNN plugins
(
    curl -Ls https://raw.githubusercontent.com/jarun/nnn/master/plugins/getplugs | sh
)

# Install npm packages
(
    cd $INSTALL_DIR/node
    print_step "Installing NPM Packages"
    ./npm.sh
)

# Install ruby packages
(
    cd $INSTALL_DIR/ruby
    print_step "Installing Ruby Gem Packages"
    ./gems.sh
)

# Install rustup
(
    print_step "Installing Rustup"
    if ! command -v rustup > /dev/null; then
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    fi
)

# Install poetry with pipx
(
    pipx install --force poetry
    poetry config virtualenvs.in-project true
)

# Install NVM Directory
(
    mkdir -p $HOME/.nvm
)

# Install Oh my ZSH
(
    if [ ! -d "$OHMYZSHDIRECTORY" ]; then
        print_step $COLOUR "Installing OH MY ZSH"
        sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    fi
)

# Install Powerline fonts
(
	print_step "Installing Powerline Fonts"

	/bin/rm -rf /tmp/fonts
	git clone https://github.com/powerline/fonts.git --depth=1 /tmp/fonts
	cd /tmp/fonts
	./install.sh
	/bin/rm -rf /tmp/fonts
)

# Customize Oh my ZSH
(
    print_step "Customizing Oh my ZSH"
	
	# Set templace robbyrussell by agnoster
	sed -i '' 's/ZSH_THEME=.*/ZSH_THEME="agnoster"/' $BASHRC

	# Add Default user to hid user@host line in prompt
	grep -q -F "DEFAULT_USER=$(whoami)" $BASHRC || echo "DEFAULT_USER=$(whoami)" >> $BASHRC
	
	# Installing Syntax Highlighting & Autosuggestions
	ZSH_SYNTAX_HIGHLIGHTING_PATH=$BREW_PATH/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
	grep -q -F "source $ZSH_SYNTAX_HIGHLIGHTING_PATH" $BASHRC || echo "source $ZSH_SYNTAX_HIGHLIGHTING_PATH" >> $BASHRC
	ZSH_AUTOSUGGESTIONS_PATH=$BREW_PATH/share/zsh-autosuggestions/zsh-autosuggestions.zsh
	grep -q -F "source $ZSH_AUTOSUGGESTIONS_PATH" $BASHRC || echo "source $ZSH_AUTOSUGGESTIONS_PATH" >> $BASHRC	
)

# Install profile sources in ZSH
(
    print_step "Installing source files to ZSH"
    grep -q -F "source $DOTFILES_DIRECTORY/env_all.sh" $BASHRC || echo "source $DOTFILES_DIRECTORY/env_all.sh" >> $BASHRC
)

# Install fzf autocompletion
(
    print_step "Installing fuzzy finder (fzf)"
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
)

# Generate new id_rsa only if not exists
(
    if [ ! -f ~/.ssh/id_ed25519 ]; then
        print_step "Installing New Elliptic Curve ed25519 Private Key"
        ssh-keygen -t ed25519 -C "$EMAIL"
    fi
)

# Configure git name, email and credentials method
(
    print_step "Configure git name and email"
    touch $GIT_CONFIG_CREDENTIALS_FILE
    git config --file $GIT_CONFIG_CREDENTIALS_FILE user.name "$NAME"
    git config --file $GIT_CONFIG_CREDENTIALS_FILE user.email $EMAIL
    git config --file $GIT_CONFIG_CREDENTIALS_FILE credential.helper $GIT_CONFIG_CRENDENTIAL_METHOD
)

# Configure MacOS X Preferences
(
    cd $INSTALL_DIR/macosx
    print_step "Setup DNS servers"
    ./dns.sh

    print_step "Installing user preferences"
    ./osx-user-defaults.sh

    print_step "Installing dock preferences"
    python3 setup-dock.py

    print_step "Default login items"
    python3 setup-login-items.py

    print_step "Bind file extensions to apps"
    python3 file-extensions.py
)

# Restore application preferences (defaults export/import; reemplaza a mackup)
print_step "Restore application preferences"
restore-defaults

exit 0
