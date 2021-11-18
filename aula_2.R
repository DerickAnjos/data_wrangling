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
# 1º: Combinamos os novos nomes desejados em um vetor

novos_nomes <- c("Observações",
                "Tempo para chegar",
                "Distância percorrida",
                "Semáforos",
                "Período",
                "Perfil")

# 2º: Em seguida, atribuimos o vetor com nomes ao dataset

names(dataset_inicial) <- novos_nomes
head(dataset_inicial)

# A função "rename" torna este trabalho mais prático
# A seguir, o argumento da função é: novo nome = nome antigo

nova_base <- rename(dataset_inicial, 
                    observacoes = Observações,
                    tempo = "Tempo para chegar",
                    distancia = 'Distância percorrida', 
                    semaforos = "Semáforos", 
                    periodo = "Período", 
                    perfil = "Perfil") # Para nomes com espaço, as aspas são 
                                       # obrigatórias

head(nova_base)

# Existe uma forma um pouco diferente de escrever as funções no R
# Trata-se do uso do operador pipe - %>% - atalho: Ctrl+Shift+M
# Com ele, tiramos o primeiro argumento do código
# É muito útil para realizar diversas funções em sequência

nova_base %>%  rename(obs = observacoes,
                      temp = tempo, 
                      dist = distancia, 
                      sem = semaforos, 
                      per = periodo, 
                      perf = perfil)

# No código acima, não criamos um novo objeto, mas poderíamos criar:

nova_base_pipe <- nova_base %>%  rename(obs = observacoes,
                        temp = tempo, 
                        dist = distancia, 
                        sem = semaforos, 
                        per = periodo, 
                        perf = perfil)

head(nova_base_pipe)
rm(nova_base_pipe)

# Também é possível utilizar a função "rename" com base na posição da variável
# Em datasets com muitas variáveis, esta função facilita a escrita do código

nova_base %>% rename(obs = 1, 
                     temp = 2, 
                     dist = 3, 
                     sem = 4, 
                     per = 5, 
                     perf = 6)

# É possível alterar apenas uma ou outra variável:

nova_base %>% rename(sem = 4, 
                     perf = 6)


#--------------------Mutate-----------------------------------------------------

# Função "mutate": apresenta duas utilidades principais
# 1. Inclui variáveis no dataset, mantendo as existentes
# 2. Transforma o conteúdo das variáveis

# Numa primeira situação, são adicionados duas variáveis a um dataset existente 
# As observações no dataset e nas variáveis devem estar igualmente ordenadas

variavel_nova_1 <- c(1:10)
variavel_nova_2 <- c(11:20)

base_inclui <- mutate(nova_base, 
                      variavel_nova_1, 
                      variavel_nova_2)

base_inclui

# Podemos utilizar o operador %>% para criar uma nova base (como antes)
# E, no mesmo código, vamos inserir as duas "variáveis novas"

nova_base %>% rename(obs = 1, 
                     temp = 2, 
                     dist = 3, 
                     sem = 4, 
                     per = 5, 
                     perf = 6) %>% 
  mutate(variavel_nova_1, 
         variavel_nova_2, 
         temp_novo = temp * 2)

# Também criamos a variável "temp_novo": é uma função de uma variável do dataset 

# A função "mutate" também pode tranformar as variáveis já existentes
# Vamos supor que gostaríamos de tranformar a variável "semáforos" em texto
# Para isto, podemos utilizar a função "replace":

base_texto_1 <- mutate(nova_base, 
                       semaforos = replace(semaforos, semaforos == 0, 'Zero'), 
                       semaforos = replace(semaforos, semaforos == 1, 'Um'),
                       semaforos = replace(semaforos, semaforos == 2, 'Dois'), 
                       semaforos = replace(semaforos, semaforos == 3, 'Três'))

head(base_texto_1)

# Em conjunto com o mutate, também pode ser utilizada a função "recode"
# A seguir, trocaremos um texto por outro texto e criaremos uma nova variável:

base_texto_2 <- mutate(nova_base, 
                       perfil_novo = recode(perfil, 
                                            'calmo' = 'perfil 1', 
                                            'moderado' = 'perfil 2', 
                                            'agressivo' = 'perfil 3'))

head(base_texto_2)

# Poderíamos manter na variável original (ao invés de criar "perfil_novo")
# Vamos utizar o "recode" para transformar um texto em valores:

base_texto_valores <- mutate(nova_base, 
                             periodo = recode(periodo,
                                              'Manhã' = 0, 
                                              'Tarde' = 1))

head(base_texto_valores)

# Um código semelhante poderia ser utilizado para gerar dummies:
# Observação: há códigos mais simples para gerar dummies, este é para praticar

base_dummy <- mutate(nova_base, perfil_agressivo = recode(perfil, 
                                                          'calmo' = 0, 
                                                          'moderado' = 0, 
                                                          'agressivo' = 1),
                     perfil_calmo = recode(perfil, 
                                           'calmo' = 1, 
                                           'moderado' = 0, 
                                           'agressivo' = 0), 
                     perfil_moderado = recode(perfil, 
                                              'calmo' = 0, 
                                              'moderado' = 1, 
                                              'agressivo' = 0))
base_dummy


#--------------------Transmute--------------------------------------------------

# Função "transmute": inclui variáveis no dataset, excluindo as existentes
# Depois de informar o dataset, informe as variáveis mantidas e adicionadas

base_exclui <- transmute(nova_base, 
                        observacoes, tempo, variavel_nova_1, 
                        variavel_nova_2)
base_exclui

# Utilizaremos o comando "cut", que converte uma var de valores em intervalos
# No exemplo abaixo, pedimos 2 intervalos tendo a mediana como referência
# Em seguida, já adicionamos novos nomes aos intervalos

base_exclui_rename <- nova_base %>% transmute(observacoes, tempo,
                                              variavel_nova_1) %>% 
  mutate(tempo_novo = recode(tempo, 
                             '10'='dez', 
                             "15"="quinze",
                             "20"="vinte",
                             "25"="vinte e cinco",
                             "30"="trinta",
                             "35"="trinta e cinco",
                             "40"="quarenta",
                             "50"="cinquenta",
                             "55"="cinquenta e cinco")) %>% 
  mutate(posicao = cut(tempo, 
                       c(0, median(tempo), Inf),
                       c('menores', 'maiores')))

head(base_exclui_rename)
median(nova_base$tempo) # verificado se o intervalo está correto


#--------------------Select-----------------------------------------------------

# Função "select": tem a finalidade principal de extair variáveis selecionadas 
# Também pode ser utilizada para reposicionar as variáveis no dataset

# Inicialmente, sem utilizar a função, poderia ser feito:

selecao_1 <- nova_base[, c('observacoes', 'tempo')]
selecao_2 <- nova_base[, c(1:3)]
