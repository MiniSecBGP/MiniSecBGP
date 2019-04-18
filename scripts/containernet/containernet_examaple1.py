#!/usr/bin/python
"""
This is the most simple example to showcase Containernet.
"""
from mininet.net import Containernet
from mininet.node import Controller
from mininet.cli import CLI
from mininet.link import TCLink
from mininet.log import info, setLogLevel
setLogLevel('info')

net = Containernet(controller=Controller)
info('*** Adding controller\n')
net.addController('c0')

info('*** Adding Docker containers - Routers\n')
r1 = net.addDocker('r1', ip='20.0.0.1', dimage="ubuntu:trusty")

info('*** Adding Mininet containers - Hosts\n')
h1 = net.addHost('h1', ip='20.0.0.2/30')
h2 = net.addHost('h2', ip='50.0.0.2/30')

#info('*** Adding Mininet containers - Router\n')
#r1 = net.addHost('r1', ip='20.0.0.1/30')

info('*** Creating links\n')
#net.addLink(g1, h1, cls=TCLink, delay='100ms', bw=1)
net.addLink(h1, r1, cls=TCLink, bw=10)
net.addLink(h2, r1, cls=TCLink, bw=10)

info('*** Setting IP addresses\n')
r1.setIP('50.0.0.1/30', intf="r1-eth1")

info('*** Starting network\n')
net.start()

info('*** Running CLI\n')
CLI(net)

info('*** Stopping network')
net.stop()
