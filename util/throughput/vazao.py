#!/usr/bin/python3

import os

def eraseCsvFile(path_csv, fileCsvToErase):
    os.remove(path_csv + fileCsvToErase)

def saveCsvToAFile(csvLine, path_csv, fileToSaveCsv):
    with open(path_csv + fileToSaveCsv, 'a') as fts:
        fts.write(csvLine + "\n")

path_log = 'log/'
path_csv = 'csv/'
fileToSaveCsv = 'vazao.csv'
fileCsvToErase = 'vazao.csv'

# matriz_full = ['rodada','qtdhosts','range1','range2','vazao','escala']
matriz_full = []
# matriz_vazao = ['qtdhosts','vazao']
matriz_vazao = []


# apagando algum arquivo csv pre-existente
try:
    eraseCsvFile(path_csv, fileCsvToErase)
except:
    print('Não foi encontrado arquivo csv previamente montado para ser excluído')
    print('Continuando o processamento...')
    pass

# montando o  cabecalho do arquivo csv
csvLine = 'qtdhosts,vazao'
# chamo a funcao para gravacao no arquivo
saveCsvToAFile(csvLine, path_csv, fileToSaveCsv)

linha = 0

# para cada arquivo do diretorio
for files in sorted(os.listdir(path_log)):

    linha_matriz_full = []
    linha_matriz_vazao = []

    # abre o arquivo para pegar os dados dentro dele
    with open(path_log + files, 'rt', encoding='utf-8', errors='ignore') as file:
        # usa um try porque se der erro no processamento do arquivo, salva no log de erros o nome do arquivo corrompido e continua o processamento
        try:
            # le as linhas do arquivo para esta variavel
            lines = file.readlines()
            # pega a antepenultima linha do arquivo (linha que contem os dados consolidado de vazao no teste)
            # Obs.: aqui que pode dar erro no processamento se o arquivo nao estiver completo. Motivo pelo qual usei o try
            # fiz esta verificacao logo no inicio do programa para agilizar o processamento em caso de erro
            last_line = lines[len(lines) - 3]

            # abaixo voltarei no processamento e montarei as duas matrizes

            # quebrando o nome do arquivo para pegar dados
            file = (files.split('_'))
            # numero da rodada
            linha_matriz_full.append(file[2])
            # numero da quantidade de conteineres (qtdhosts)
            linha_matriz_full.append(file[4])
            linha_matriz_vazao.append(file[4])
            # numero da range1
            linha_matriz_full.append(file[5][-1])
            # numero da range2
            linha_matriz_full.append(file[6][0])

            # aqui voltarei a processar os dados da variavel "last_line" criada no inicio do try
            # primeiro eu quebro a last_line nos espacos
            last_line_sem_espacos = []
            for c in last_line.split(' '):
                # depois gravo somente os valores reais (diferentes de espaco) na lista last_line_sem_espacos
                if (c != ''):
                    last_line_sem_espacos.append(c)
            # valor da vazao
            linha_matriz_full.append(last_line_sem_espacos[6])
            linha_matriz_vazao.append(last_line_sem_espacos[6])
            # tipo de escala
            linha_matriz_full.append(last_line_sem_espacos[7])

            # gravos as linhas na matriz final
            matriz_full.append(linha_matriz_full)
            matriz_vazao.append(linha_matriz_vazao)

            # monto a linha do csv que sera gravado no arquivo
            csvLine = (matriz_vazao[linha][0] + ',' + matriz_vazao[linha][1])
            # chamo a funcao para gravacao no arquivo
            saveCsvToAFile(csvLine, path_csv, fileToSaveCsv)
            # incremento a variavel linha para gravar a proxima linha no proximo loop do for
            linha = linha + 1

        except IndexError:
            print('erro no processamento do arquivo ' + files)
            pass