
library('tidyverse')

# O dataset contém informações sobre a pandemia do COVID-19 em diversos países
# O dataset é um arquivo CSV, com informações separadas por vírgulas

base_covid <- read.csv(file = "(2.2) WHO COVID-19 Global Table.csv", 
                       header = T, 
                       sep = ',',
                       dec = '.')

# O primeiro argumento indica o nome do dataset
# O argumento "header" indica que a primeia linha contém os nomes das variáveis
# O argumento "sep" indica que a separação das colunas é feita por vírgulas
# O argumento "dec" indica que a separação dos decimais ocorre por pontos

dim(base_covid)
names(base_covid)

# Os nomes estão ruins, vamos alterar e simplificar os nomes das variáveis:

# names(base_covid) <- c('xxx', 'xxx' '.....')
base_covid <- base_covid %>% rename(nome = 1, regiao = 2, casos_total = 3,
                                    casos_relativo = 4,
                                    casos_semana = 5,
                                    casos_semana_relativo = 6,
                                    casos_dia = 7,
                                    mortes_total = 8,
                                    mortes_relativo = 9,
                                    mortes_semana = 10,
                                    mortes_semana_relativo = 11,
                                    mortes_dia = 12,
                                    tipo_transmissao = 13)

names(base_covid)
glimpse(base_covid)

# A seguir, vamos alterar as categorias da variável "tipo_transimssao"
# Podemos utilizar a função mutate e, por exemplo, traduzir para português
# Também podemos criar uma categoria para a variável "casos_relativo"

# Primeiramente: identificar as categorias da variável "tipo_transimssao"
table(base_covid$tipo_transmissao)
unique(base_covid$tipo_transmissao)

# Em uma rápida análise dos países, vemos que há "Global" e "Other"
# Antes de criar categorias para "casos_relativo", vamos excluí-los do dataset
base_covid <- base_covid[base_covid$nome != 'Other' &
                           base_covid$nome != 'Global',]

# Podemos trocar os nomes de "tipo_transimssao" com o "mutate" e "recode"
# Podemos criar a nova categoria para "casos_relativo" com "mutate" e "cut"
base_covid <- base_covid %>% 
  mutate(tipo_transmissao = recode(tipo_transmissao,
                        "Clusters of cases" = "Casos Concentrados",
                        "Community transmission" = "Transmissão Comunitária",
                        "No cases" = "Sem Casos",
                        "Not applicable" = "Não Aplicável",
                        "Pending" = "Pendente",
                        "Sporadic cases" = "Casos Esporádicos")) %>% 
  mutate(grupos = cut(casos_relativo,
                      c(-Inf, quantile(base_covid$casos_relativo, type = 5, 
                                     probs = c(.25, .5, .75),T),+Inf),
                      c('primeiro_quartil', 
                        'segundo_quartil', 
                        'terceiro_quartil', 
                        'quarto_quartil')))

table(base_covid$grupos)

# Vamos excluir a variável "mortes_dia", pois não vamos utilizar
# Ao mesmo tempo, vamos trazer a variável "grupos" para o começo do dataset

base_covid <- base_covid %>% select(grupos, everything(), -mortes_dia)

# Em seguida, vamos agrupar o dataset com base na variável "grupos"
# Vamos criar um dataset com informações de resumo (média, desvio padrão, ...)
# No final, realizar o ungroup para manter o dataset na estrutura original
covid_resumo <- base_covid %>% group_by(grupos) %>% 
  summarise(média = mean(casos_dia), 
            desvio_pad = sd(casos_dia),
            mediana = median(casos_dia),
            tereiro_quartil = quantile(casos_dia, type = 5, probs = .75),
            quantidade = n()) %>% 
  ungroup() %>% droplevels(.)

# Como já fizemos o ungroup acima, poderíamos realizar uma análise diferente:
covid_resumo_2 <- base_covid %>% group_by(regiao) %>% 
  summarise(qntd = n(),
            média = mean(casos_dia),
            mediana = median(casos_dia)) %>% ungroup() %>% droplevels(.)

# Vamos adicionar duas novas variáveis ao dataset utilizando a função "join"
# As variáveis estão na planilha em Excel WBD Pib per Capita
# Vamos trazer "income group" e "PIB em 2019" utilizando "right join"

library(readxl)

pib2019 <- read_excel('(2.3) WBD PIB per Capita.xls')

glimpse(pib2019)

# A chave para o merge é o nome do país, mas é necessária a alteração no nome
# Vamos aproveitar o mesmo código e fazer algumas alterações adicionais

pib2019 <- pib2019 %>% rename(nome = `Country Name`, 
                              cod = `Country Code`,
                              income_group = `Income group`,
                              pib = `2019`)

base_join <- pib2019 %>% right_join(base_covid, by = 'nome') %>% 
  select(everything(), -cod) %>% 
  rename(grupo_renda = 'income_group') %>% 
  mutate(grupo_renda = recode(grupo_renda, 
                              'High income' = 'PIB mais elevado',
                              "Upper middle income" = "PIB Elevado",
                              "Lower middle income" = "PIB Baixo",
                              "Low income" = "PIB Muito Baixo"))

# Como é um "right join", levamos as variáveis do PIB2019 para a base_covid
# Portanto, a base_covid_2 contém as mesmas observações da base_covid
# Note que surgem os NAs nos casos não identificados

# Vamos analisar com base na nova variável adicionada pelo merge

base_renda <- base_join %>% group_by(grupo_renda) %>% 
  summarise(qntd = n(),
            média = mean(casos_dia), 
            mediana = median(casos_dia)) %>% ungroup() %>% droplevels(.)

# Ou mesmo um gráfico para ilustrar por imagem:

base_join %>% group_by(grupo_renda) %>% 
  summarise(qntd = n(),
            média = mean(casos_dia), 
            mediana = median(casos_dia)) %>% ungroup() %>% droplevels(.) %>% 
  ggplot()+
  geom_col(aes(x = grupo_renda, y = média), fill = 'darkorchid') +
  labs(x = 'Grupo de Renda',
       y = 'Média de casos por dia', 
       title = 'Análise COVID')

