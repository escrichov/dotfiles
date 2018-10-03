#!/usr/bin/env bash


DOTFILES_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
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

SUDO_TIMEOUT_TEMPORARY_FILE=/tmp/temporal_sudo_timeout
SUDO_TIMEOUT_FILE=/etc/sudoers.d/temporal_sudo_timeout


function _term_only_exit() {
    exit 1
}

function _term() {
    echo-colour red "Installation script stopped"
    echo-colour red "Revert unlimited sudo timeout"
    reset_sudo_timeout
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

function unlimited_sudo_timeout ()
{
    sudo rm -f $SUDO_TIMEOUT_TEMPORARY_FILE
    sudo echo "Defaults    timestamp_timeout=-1" > $SUDO_TIMEOUT_TEMPORARY_FILE
    sudo chmod 440 $SUDO_TIMEOUT_TEMPORARY_FILE
    sudo chown root $SUDO_TIMEOUT_TEMPORARY_FILE
    sudo visudo -c -f $SUDO_TIMEOUT_TEMPORARY_FILE || print_error "Failed to set unlimited sudo timeout"
    sudo mv $SUDO_TIMEOUT_TEMPORARY_FILE $SUDO_TIMEOUT_FILE
}

function reset_sudo_timeout ()
{
    sudo rm -f $SUDO_TIMEOUT_FILE
    sudo rm -f $SUDO_TIMEOUT_TEMPORARY_FILE
    # Force input password the next time
    sudo -K
}


# Source all environment
source $ALL_ENVIRONMENT_FILE

# Catch signals to exit correctly
trap _term_only_exit SIGTERM
trap _term_only_exit INT

# Print dotfiles title
print_title

# Ask for sudo only first
print_step "Ask for sudo password only once"
sudo -v # ask for sudo upfront

# Set unlimited sudo timeout without touching /etc/sudoers file
print_step "Set unlimited sudo timeout temporary"
unlimited_sudo_timeout

# Catch signals to exit correctly and revert sudo timeout
trap _term SIGTERM
trap _term INT

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
        /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
    else
        print_step "Updating Brew"
        brew update
        brew upgrade
    fi

    # Disable analytics
    brew analytics off
)

# Install dotfiles
(
    print_step "Installing dotfiles"
    stow --target=$HOME --dir=$DOTFILES_DIRECTORY dots
)

# Install Brew packages
(
    cd $INSTALL_DIR/brew
    print_step "Installing Brew packages and applications"
    brew bundle
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

# Install Oh my ZSH
(
    if [ ! -d "$OHMYZSHDIRECTORY" ]; then
        print_step $COLOUR "Installing OH MY ZSH"
        sh -c "$(wget https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O -)"
    fi
)

# Install profile sources in ZSH
(
    print_step "Installing source files to ZSH"
    grep -q -F "source $DOTFILES_DIRECTORY/env_all.sh" $BASHRC || echo "source $DOTFILES_DIRECTORY/env_all.sh" >> $BASHRC
    source $BASHRC
)

# Install fzf autocompletion
(
    print_step "Installing fuzzy finder (fzf)"
    $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
)

# Install python pip
(
    print_step "Installing python pip"
    brew postinstall python2
    brew postinstall python3
)

# Generate new id_rsa only if not exists
(
    if [ ! -f ~/.ssh/id_rsa ]; then
        print_step "Installing New RSA Private Key"
        ssh-keygen -t rsa -b 4096 -C "$EMAIL"
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

    print_step "Xcode command line developer tools"
    ./xcode.sh

    print_step "Installing system preferences"
    sudo ./osx-system-defaults.sh

    print_step "Installing user preferences"
    ./osx-user-defaults.sh

    print_step "Installing dock preferences"
    /usr/bin/python setup-dock.py

    print_step "Default login items"
    /usr/bin/python setup-login-items.py

    print_step "Bind file extensions to apps"
    /usr/bin/python file-extensions.py
)

# Restore configuration of apps
print_step "Restore apps configuration and preferences"
mackup restore -f

# Revert sudo timeout
print_step "Revert unlimited sudo timeout"
reset_sudo_timeout

exit 0
