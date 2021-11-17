# Data Wrangling R

# Introdução ao pacote dplyr (https://dplyr.tidyverse.org/)

# O pacote dplyr está contido no tidyverse
# dplyr: contém muitas funções comuns na manipulação de dados

install.packages('tidyverse')
library('tidyverse')

#--------------------Importar os datasets---------------------------------------

# Dois datasets serão utilizados na apresentação central dos tópicos:
# "dataset_inicial" - Fonte: Fávero & Belfiore (2017, Cap. 12)
# "dataset_merge" - utilizado em análises futuras, mas já podemos importá-lo

# Como estão em Excel, vamos importá-los da seguinte forma:

library('readxl')

dataset_inicial <- read_excel("(1.2) Dataset Aula Data Wrangling.xls")
dataset_merge <- read_excel("(1.3) Dataset Aula Data Wrangling (Join).xls")

# Abrindo o dataset em outra aba
view(dataset_inicial)

# Exibindo primeiras e últimas 5 linhas do dataset
head(dataset_inicial, 5)
tail(dataset_inicial,5)

# Exibindo a estrutura do dataset
str(dataset_inicial)
glimpse(dataset_inicial) # Prefiro utilizar essa devida a organização dos dados

# Exibindo no console
print(dataset_inicial)

# Exibindo as dimensões do dataset (lin x col)
dim(dataset_inicial)

# Exibindo o nome das variáveis (colunas)
names(dataset_inicial)


#--------------------Rename-----------------------------------------------------

# Função "rename": utilizada para alterar o nome das variáveis

# No dataset de exemplo, os nomes das variáveis contêm:
# Espaços, maiúsculas, acentos e caracteres especiais...
# É melhor não utilizá-los, podem gerar conflito e dificultam a escrita

# Inicialmente, sem utilizar a função, poderíamos fazer da seguinte forma:
# 1º:Combinamos os novos nomes desejados em um vetor
