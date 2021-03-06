#!/bin/bash

# MiniSecBGP install script for Ubuntu 18.04.1 Server LTS (Bionic Beaver)
# Emerson Barea (emerson.barea@gmail.com)

function welcome() {
    printf '\n%s\n' 'This script creates the complete environment for MiniSecBGP.
                   Some requirements must be met:
                   - Ubuntu 18.04.1 Server LTS (Bionic Beaver)
                   - 2 NICs (one for administration and other for cluster nodes network communication)
                   - Internet access
                   - User with "sudo" rights
		   - MiniSecBGP will be installed in current user home directory
                   Note: the user "minisecbgp" will be created, so it should not exist previously.'
}

function qtd_hosts() {
    printf '\n%s' 'How many cluster nodes do you want to create? (write only numbers. Ex.: 3): '
    read var_qtd_hosts
    re='^[0-9]+$'
    if ! [[ $var_qtd_hosts =~ $re ]] ; then
        printf '\e[1;31m%-6s\e[m' 'error: Write only numbers'
        qtd_hosts;
    fi
}

function update_SO_install_packages() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Installing SO updates and packages install...'
    printf '\e[1;33m%-6s\e[m\n' 'Please, confirm if the computer has internet connectivity.'
    sudo apt update
    sudo apt upgrade -y
    sudo apt install htop whois -y
}

function network_configuration() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Configuring network interfaces...'
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all network previous configuration and renaming NIC interfaces to "eth0" and "eth1".'
    sudo sed -i -- 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"/g' /etc/default/grub
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    printf '\e[1;33m%-6s\e[m\n' 'eth0 will be configured to DHCP client after reboot'
    printf '%s\n' $'auto lo\niface lo inet loopback\n\nallow-hotplug eth0\niface eth0 inet dhcp' | sudo tee /etc/network/interfaces
}

function hosts_file() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Configuring "/etc/hosts" file...'
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous configuration.'
    sudo hostnamectl set-hostname localhost
    printf '%s\n' "127.0.0.1 localhost.localdomain localhost" | sudo tee /etc/hosts
    for ((i=1; i<=$var_qtd_hosts; i++)); do
        printf '%s\n' "192.168.254.$i    node$i" | sudo tee --append /etc/hosts; done
}

function user() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Creating "maxinet" user for MaxiNet to work...'
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous "maxinet" user data.'
    sudo userdel -r maxinet 2> /dev/null
    sudo useradd -m -p $(mkpasswd -m sha-512 -S saltsalt -s <<< maxinet) -s /bin/bash maxinet
    printf '\e[1;33m%-6s\e[m\n' 'Putting "maxinet" user in sudoers'
    printf '%s\n' 'maxinet     ALL=NOPASSWD: ALL' | sudo tee --append /etc/sudoers
}

function ssh_file() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Configuring SSH...'
    sudo sed -i -- 's/#PermitTunnel no/PermitTunnel yes/g' /etc/ssh/sshd_config
    printf '\n\e[1;33m%-6s\e[m\n' 'Creating and exchanging SSH key for "maxinet" user'
    sudo -u maxinet ssh-keygen -t rsa -N "" -f /home/maxinet/.ssh/id_rsa
    printf '\n\e[1;33m%-6s\e[m\n' 'Adding "maxinet" user key in the authorized_keys'
    for (( c=1; c<=$var_qtd_hosts; c++ )); do
        sudo -u maxinet cat /home/maxinet/.ssh/id_rsa.pub | \
        sudo -u maxinet tee --append /home/maxinet/.ssh/authorized_keys; done
    printf '\n\e[1;33m%-6s\e[m\n' 'Changing hostnames keys in authorized_keys'
    for i in $(sudo -u maxinet cat -n /home/maxinet/.ssh/authorized_keys | awk '{print $1}'); do
        sudo -u maxinet sed -Ei "${i}s/@.*/@node$i/" /home/maxinet/.ssh/authorized_keys; done
    printf '\n%s\n' 'showing /home/maxinet/.ssh/authorized_keys'
    sudo -u maxinet cat /home/maxinet/.ssh/authorized_keys
    sudo -u maxinet chmod 755 /home/maxinet/.ssh/authorized_keys
    printf '%s\n' $'Host *\nStrictHostKeyChecking no' | \
	sudo -u maxinet tee --append /home/maxinet/.ssh/config
    sudo -u maxinet chmod 400 /home/maxinet/.ssh/config
}

function node_file() {
    printf '\n\e[1;33m%-6s\e[m\n' '-- Creating configuration file for all cluster nodes ...'
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous configuration.'
    sudo -u $USER rm -rf $INSTALL_DIR/nodes 2> /dev/null
    sudo -u $USER mkdir -p $INSTALL_DIR/nodes
    for ((i=1; i<=$var_qtd_hosts; i++)); do
        sudo -u $USER cp $INSTALL_DIR/scripts/nodes/template_node.sh $INSTALL_DIR/nodes/node$i.sh;
        sudo -u $USER sed -i -- 's/<node_number>/'$i'/g' $INSTALL_DIR/nodes/node$i.sh;
        sudo -u $USER chmod 755 $INSTALL_DIR/nodes/node$i.sh; done
    printf '\n%s\n' 'showing nodes file'
    cat $INSTALL_DIR/nodes/node*.sh
}

function install_app_containernet() {
    printf '\n\e[1;32m%-6s\e[m\n' '-- Installing Containernet ...'
    printf '\n\e[1;33m%-6s\e[m\n' 'Resolving requirements'
    sudo apt-get install ansible git aptitude -y
    sudo -u $USER git clone https://github.com/containernet/containernet.git $INSTALL_DIR/containernet
    cd $INSTALL_DIR/containernet/ansible
    sudo ansible-playbook -i "localhost," -c local install.yml
    cd ..
    sudo python setup.py install
}

function install_metis() {
    printf '\e[1;33m%-6s%s\e[m\n' 'Installing METIS in ' $INSTALL_DIR/metis
    printf '\n\e[1;33m%-6s\e[m\n' 'Resolving requirements'
    sudo apt install cmake -y
    printf '\e[1;33m%-6s\e[m\n' 'Erasing all previous configuration.'
    sudo -u $USER rm -rf $INSTALL_DIR/metis-5.1.0* 2> /dev/null

    #[ -f $INSTALL_DIR/metis-5.1.0.tar.gz ] || sudo -u $USER wget http://glaros.dtc.umn.edu/gkhome/fetch/sw/metis/metis-5.1.0.tar.gz -P $INSTALL_DIR
    [ -f $INSTALL_DIR/metis-5.1.0.tar.gz ] || sudo -u $USER wget http://192.168.56.1/metis-5.1.0.tar.gz -P $INSTALL_DIR 
    
    sudo -u $USER tar -xvzf $INSTALL_DIR/metis-5.1.0.tar.gz -C $INSTALL_DIR
    cd $INSTALL_DIR/metis-5.1.0
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
    sudo -u $USER rm -rf $INSTALL_DIR/maxinet
    sudo -u $USER git clone git://github.com/MaxiNet/MaxiNet.git $INSTALL_DIR/MaxiNet
    cd $INSTALL_DIR/MaxiNet
    sudo -u $USER git checkout v1.2
    sudo make install
    sudo cp $INSTALL_DIR/MaxiNet/share/MaxiNet-cfg-sample /etc/MaxiNet.cfg
    printf '\e[1;33m%-6s\e[m\n' 'Configuring MaxiNet config file.'
    sudo sed -i -- 's/password = HalloWelt/password = maxinet/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/controller = 192.168.123.1:6633/controller = 192.168.254.1:6633/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/logLevel = INFO/logLevel = ERROR/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/sshuser = root/sshuser = maxinet/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/usesudo = False/usesudo = True/g' /etc/MaxiNet.cfg
    sudo sed -i -- 's/ip = 192.168.123.1/ip = 192.168.254.1/g' /etc/MaxiNet.cfg
    sudo sed -i -- 19,'$d' /etc/MaxiNet.cfg
    for ((i=1; i<=$var_qtd_hosts; i++)); do 
        printf '[node'$i$'] \nip = 192.168.254.'$i$' \nshare = 1\n\n' | sudo tee --append /etc/MaxiNet.cfg; done
    sudo cat /etc/MaxiNet.cfg    
}

# set up build directory
USER=$(whoami)
HOME_DIR=$(echo $HOME)
INSTALL_DIR=$HOME_DIR/MiniSecBGP

welcome;
qtd_hosts;
update_SO_install_packages;
network_configuration;
hosts_file;
user;
ssh_file;
node_file;
install_app_containernet;
install_app_maxinet;
