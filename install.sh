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
    sudo add-apt-repository universe
    sudo apt update
    sudo apt install language-pack-pt -y
    sudo apt upgrade -y
    sudo apt install python python3 python-pip python3-pip -y
}

function network_configuration() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Configuring network interfaces...'
    printf '\e[1;33m%-6s\e[m\n' 'Removing Netplan, erasing all previous configuration and renaming NIC interfaces to "eth0" and "eth1".'
    sudo apt autoremove netplan netplan.io nplan -y
    sudo sed -i -- 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    printf '\e[1;33m%-6s\e[m\n' 'eth0 will be configured to DHCP client after reboot'
    printf '%s\n' $'auto lo\niface lo inet loopback\n\nallow-hotplug eth0\niface eth0 inet dhcp' | sudo tee /etc/network/interfaces
}

function install_metis() {
    printf '\e[1;33m%-6s%s\e[m\n' 'Installing METIS in ' $BUILD_DIR/metis
    printf '\n\e[1;33m%-6s\e[m\n' 'Resolving requirements'
    sudo apt install cmake -y
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous configuration.'
    sudo -u mininet rm -rf $BUILD_DIR/metis-5.1.0* 2> /dev/null
    
    #sudo -u mininet wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz -P $BUILD_DIR
    sudo -u mininet wget http://192.168.56.254/metis-5.1.0.tar.gz -P $BUILD_DIR
    
    sudo -u mininet tar -xvzf $BUILD_DIR/metis-5.1.0.tar.gz -C $BUILD_DIR
    cd $BUILD_DIR/metis-5.1.0
    sudo make config shared=1
    sudo make
    sudo make install
    sudo ldconfig
}

function install_app_maxinet() {
    printf '\n\e[1;32m%-6s\e[m\n' '-- Installing MaxiNet ...'
    printf '\n\e[1;33m%-6s\e[m\n' 'Resolving requirements'
    sudo -H pip install --upgrade --force-reinstall -U Pyro4

    install_metis;

    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous configuration.'
    sudo -u mininet rm -rf $BUILD_DIR/maxinet
    sudo -u mininet git clone git://github.com/MaxiNet/MaxiNet.git $BUILD_DIR/MaxiNet
    cd $BUILD_DIR/MaxiNet
    sudo -u mininet git checkout v1.2
    sudo make install
    sudo cp $BUILD_DIR/MaxiNet/share/MaxiNet-cfg-sample /etc/MaxiNet.cfg
    printf '\e[1;33m%-6s\e[m\n' 'Configuring MaxiNet config file.'
    sudo sed -i -- 's/password = HalloWelt/password = abc123/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/controller = 192.168.123.1:6633/controller = 192.168.254.1:6633/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/logLevel = INFO/logLevel = ERROR/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/sshuser = root/sshuser = mininet/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/usesudo = False/usesudo = True/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/ip = 192.168.123.1/ip = 192.168.254.1/g' /etc/MaxiNet.cfg
    sudo sed -i -- 19,'$d' /etc/MaxiNet.cfg
    for ((i=1; i<=$var_qtd_hosts; i++)); do 
        printf '[node'$i$'] \nip = 192.168.254.'$i$' \nshare = 1\n\n' | sudo tee --append /etc/MaxiNet.cfg; done
    sudo cat /etc/MaxiNet.cfg    
}

# set up build directory
LOCAL_DIR=$(pwd)
BUILD_DIR=/home/mininet
MINISECBGP_DIR=$BUILD_DIR/MiniSecBGP

welcome;
update_SO_install_packages;
#network_configuration;
