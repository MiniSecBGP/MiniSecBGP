#!/bin/bash

# MiniSecBGP install script for Ubuntu 18.04.1 Server LTS (Bionic Beaver)
# Emerson Barea (emerson.barea@gmail.com)

function welcome() {
    printf '\n%s\n' 'This script creates the complete environment for MiniSecBGP.
                   Some requirements must be met:
                   - Ubuntu 18.04.1 Server LTS (Bionic Beaver)
                   - 2 NICs (one for administration and other for cluster nodes network communication)
                   - Internet access
                   - Initial user with "sudo" rights
                   Note: the user "minisecbgp" will be created, so it should not exist previously.'
}

function update_SO_install_packages() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Installing SO updates and packages install...'
    printf '\e[1;33m%-6s\e[m\n' 'Please, confirm if the computer has internet connectivity.'
    sudo apt update
    sudo apt install language-pack-pt -y
    sudo apt upgrade -y
    sudo apt install python python3 python-pip python3-pip -y
}

welcome;
update_SO_install_packages;
