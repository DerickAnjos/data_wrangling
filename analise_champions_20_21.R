# Dataset Champions League 2020-2021
# O dataset contém os resultados dos jogos da temporada 20-21 da UEFA Champions
# Fonte: https://www.kaggle.com/datasets, enviado por Marco Carujo

library('tidyverse')
library('read')

jogos <- read.csv(file = '(5.2) Champions League 2020-2021.csv')
glimpse(jogos)

# De forma geral, o dataset já está bastante organizado
# As observações são os jogos que acontecetaram ao longo do campeonato
# As variáveis são as informações pertinentes aos jogos

# Uma variável que não consta na lista é o time vencedor do jogo
# Vamos criar usando o mutate e a função case_when para definir a fórmula
# O case_when funciona como um "se -> então"

jogos <- jogos %>% mutate(time_vencedor = case_when(
  c(jogos$team_home_score-jogos$team_away_score) == 0 ~ 'empate',
  c(jogos$team_home_score-jogos$team_away_score) > 0 ~ 'mandante',
  c(jogos$team_home_score-jogos$team_away_score) < 0 ~ 'visitante')) %>% 
  relocate(time_vencedor, .after = team_away_score)

# Vamos gerar um gráfico para visualizar melhor a informação resultante
ggplot(jogos) + 
  geom_bar(aes(x = time_vencedor), fill = 'aquamarine4') +
  labs(x = 'Vencedor', y = "Quatidade") +
  theme_bw()

# Vamos identificar as fases da competição e fazer uma análise mais específica:
fases <- word(jogos$stage, 1)

# Note que, ao pedirmos a primeria palavra, o comando retornou "vazio"
# Ao analisar o dataset, nota-se que existe um espaço antes do texto
# Podemos simplesmente pedir a segunda palavra:
fases <- word(jogos$stage,2)

# Também poderíamos excluir o espaço e pedir a primeira palavra
# Ambos apresentam o mesmo resultado
ajuste <- sub('^.', '', jogos$stage)
fases_2 <- word(ajuste, 1)

# Vamos adicionar a variável ao dataset, mas renomeando as categorias
jogos <- jogos %>% mutate(fase = recode(fases, 
                                        'Group' = 1, 
                                        'Round' = 2, 
                                        'Quarter-finals' = 3,
                                        'Semi-finals' = 4,
                                        'Final' = 5)) %>% 
  relocate(fase, .after = stage)

# Vamos analisar o gráfico de acordo com as fases da competição:
ggplot(jogos)+
  geom_bar(aes(x = interaction(time_vencedor, fase), fill = factor(fase))) +
  labs(x = "Vencedor por Fase",
       y =  "Quantidade") +
  scale_fill_brewer(palette = 18) +
  theme_bw()

# Uma informação interessante seria identificar os jogadores que fizeram os gols
# Esta informação está na variável "events_list" que é uma string mais complexa
# Precisamos retirar a informação específica, então vamos procurar um padrão
# A informação que queremos está sempre após -- 'Goal', 'action_player_1': ' --
extrai_gol <- str_extract_all(jogos$events_list,
                              "'Goal', 'action_player_1': '\\w*(.*?)\\w*\\'",
                              simplify = TRUE)
                          
# Acima, utilizamos regex (regular expression), úteis para trabalhar em strings
# Embora não seja nosso foco, é importante conhecer a existência
# O str_extract_all pede para extrair em todas as ocorrências do padrão

# Pedimos para extrair qualquer palavra (\w) contida entre as extremidades:
# Extremidade 1: 'Goal', 'action_player_1': '
# Extremidade 2: ' (só o apóstrofo)
# A seguir, apenas faremos uma limpeza no texto
extrai_gol <- gsub("'Goal', 'action_player_1': ", "", extrai_gol)
extrai_gol <- gsub("'", "", extrai_gol)

# O mesmo critério vamos usar para extrair os gols de pênalti
extrai_penalty <- str_extract_all(jogos$events_list, 
                "'event_type': 'Penalty', 'action_player_1': '\\w*(.*?)\\w*\\'",
                simplify = TRUE)

extrai_penalty <- gsub("'event_type': 'Penalty', 'action_player_1': ", "", 
                       extrai_penalty)
extrai_penalty <- gsub("'", "", extrai_penalty)

# Por fim, podemos pedir uma tabela de frequências dos gols
sort(table(cbind(extrai_gol, extrai_penalty)), decreasing = T)
