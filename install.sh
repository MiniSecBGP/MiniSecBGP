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

welcome;
