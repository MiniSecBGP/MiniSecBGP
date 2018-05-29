--> banda_entre_routers.py

O arquivo banda_entre_routers.py é responsável por realizar testes de vazão com iPerf3 entre pares de contêineres Mininet.
Em sua configuração padrão, são realizados 10 rodadas de testes com o número de contêineres partindo de 2 até 100. Sempre com um contêiner enviando tráfego (iPerf3) para outro, por isso, o número de instâncias deve ser sempre par.

Os resultados são salvos no diretório "log", onde o nome do arquivo segue a estrutura abaixo:

iperf_rodada_9_qtdhosts_98_range81_82.txt

Onde:
- rodada_9 corresponde a 9ª rodada de testes
- qtdhosts_98 corresponde a um teste com 98 hosts (distribuídos em 49 pares de emissores e receptores de tráfego)
- range81_82 informa que este arquivo contém os dados de tráfego do par de contêiner 81 e 82 desse teste.


--> vazao.py

O arquivo vazao.py monta o arquivo "vazao.csv" (armazenado na pasta "csv") com um parsing dos resultados finais do iPerf3. Cada linha desse parsing contém a rodada e vazao correspondente de cada arquivo gerado pelo banda_entre_routers.py.
O arquivo "vazao.csv" é processado pelo script em R denominado "vazao.r".

--> vazao.r

O arquivo vazao.r (armazenado na pasta "R") contém o código que gera a figura contendo boxplots que apresentam a relação de vazão observada no servidor.
