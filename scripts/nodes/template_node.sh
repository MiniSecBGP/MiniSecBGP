#!/bin/bash

node=<node_number>

function welcome() {
    printf 'This script will configure:\n - hostname: node'$node'\n - eth1 address: 192.168.254.'$node
}

function ask() {
    printf '\nDo you really want to continue? ([y]/n) '
    read question
    if [ "$question" != "" ] && [ "$question" != "Y" ] && [ "$question" != "y" ] \
        && [ "$question" != "N" ] && [ "$question" != "n" ]; then
            printf '\e[1;31m%-6s\e[m' 'error: Press only Y|y or N|n'
            ask;
    fi
}

function configure_node() {
    # Setting hostname
    sudo hostnamectl set-hostname node$node;
    # Setting eth1 configuration in /etc/network/interfaces
    printf $'\nallow-hotplug eth1\niface eth1 inet static\naddress 192.168.254.'$node$'\nnetmask 255.255.255.0\n\n' | sudo tee --append /etc/network/interfaces;
    sudo reboot;
}

welcome;
ask;
if [ "$question" = "" ] || [ "$question" = "Y" ] || [ "$question" = "y" ] ; then
    configure_node;
fi
