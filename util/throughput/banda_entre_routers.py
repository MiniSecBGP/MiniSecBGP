#!/usr/bin/python

from mininet.topo import Topo
from mininet.net import Mininet
from mininet.util import dumpNodeConnections

import time

class MyTopo(Topo):
    def build(self, n=2):
        for j in range(n):
            if j > 0 and j % 2 == 1:
                host1 = self.addHost('h%s' % (j), ip = '20.20.20.%s/24' % (j))
                host2 = self.addHost('h%s' % (j+1), ip = '20.20.20.%s/24' % (j+1))
                self.addLink(host1, host2)

def simpleTest():

    qtd_vezes = 10 
    qtd_hosts = 100

    for i in range(qtd_vezes):
        topo = MyTopo(n=qtd_hosts)
        net = Mininet(topo)
        dumpNodeConnections(net.hosts)
        for h in range(qtd_hosts):
            if h > 0 and h % 2 == 1:
                for l in range(1,h+1):
                    if l > 0 and l % 2 == 1:
                        host1 = net.get('h%s' % (l))
                        host1.cmd('iperf3 -s &')
                        host2 = net.get('h%s' % (l+1))
                        host2.cmd('iperf3 -c 20.20.20.%s -Z > log/iperf_rodada_%s_qtdhosts_%s_range%s_%s.txt &' % (l,i+1,h+1,l,l+1))
                        print('iperf client: h%s conectando no 20.20.20.%s' % (l+1,l))
                time.sleep(30)
                print('')

if __name__ == '__main__':
    #setLogLevel('info')
    simpleTest()
