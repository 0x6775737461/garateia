#!/usr/bin/env bash

# obtendo o arquivo xml que contém as notícias
get_news() {
   local url='https://www.douradosagora.com.br/feed'

   # verificando se o diretório já existe
   test -d data || mkdir data 

   # se for a primeira vez executando o script,
   # não vai existir o arquivo de informação sobre
   # em qual segundo o wget foi executado.
   # por isso fazemos a checagem para executar ou não
   # a função de verificação de tempo.
   test ! -e data/last_acess.txt || last_acess && {
      wget -q --limit-rate=100k -t 3 -O data/feed.xml "$url"
      date '+%s' > data/last_acess.txt
      exit 0
   }

   echo \
      'Espere completar 5 minutos para a próxima requisição'
}

last_acess() {
   # último acesso em segundos no formato do unix time
   local change_time=$(<data/last_acess.txt)

   # aqui pegamos o tempo em segundos do unix time
   local actual_time=$(date '+%s')

   # a quantidade de segundos que se passaram desde a
   # última vez que baixamos o arquivo xml
   local time_diff=$(( actual_time - change_time ))

   # 5 min == 300s
   test $time_diff -gt 300
   return $?
}

#TODO:
# - filtrar título, texto e link
# - organizar as informações
# - traduzir as codificações html
# - enviar a notícia para o telegram

main() {
   get_news
}

main "$@"
