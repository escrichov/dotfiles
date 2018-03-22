# Dotfiles

Personal shell dotfiles

## Install

Download:

```
git clone https://github.com/escrichov/dotfiles ~/dotfiles
```

Run this scripts and then follow the instructions:

```
cd ~/dotfiles && ./install.sh
```

Modify your secrets:

```
cp environment/env_secret_default.sh environment/env_secret.sh
```

Configure aws credentials:

```
aws configure
```

Update system:

```
update
```

## Steps for setup machine

1. Set the wifi password or connect lan cable

2. Setup Lastpass/1Password/Apple Keychain.

3. Set Apple ID. 

4. Install dropbox.
5. Git clone .dotfiles and install it. 
6. Setup Chrome with user. 
7. Setup Mail and Calendar. 
8. Install apps that you can not automate. Examples: "Logitech Options", "Game Maker Studio", ...
