#!/usr/bin/env bash

# obtendo o arquivo xml que contém as notícias
get_news() {
   local url='https://www.douradosagora.com.br/feed'
   local new_title=''

   # verificando se o diretório já existe
   test -d data || mkdir data 

   # se for a primeira vez executando o script,
   # não vai existir o arquivo de informação sobre
   # em qual segundo o wget foi executado.
   # por isso fazemos a checagem para executar ou não
   # a função de verificação de tempo.
   test ! -e data/last_acess.txt || last_acess && {
      # TODO: testar se wget obteve sucesso
      wget -q --limit-rate=100k -t 3 -O data/feed.xml "$url"
      date '+%s' > data/last_acess.txt

      exit 0
   }

   # TODO: coloque dentro do teste acima
   # pegando o título da última notícia
   local new_title=$(get_title 6)

   echo "[${new_title}]"

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

get_title() {
   local tmp_title=''
   # TODO: será um problema se o usuário passar um valor diferente de [0-9] ?
   declare -i index="$1"

   # o primeiro valor com a tag 'title' é o nome do site,
   # precisamos pular isso.
   ((index++))

   # o limite de notícias no arquivo xml é 11
   [[ $1 =~ ^([0-9]|1[01])$ ]] && {
      # pegando a notícia especificada no parâmetro $1
      tmp_title=$(grep -Eo -m $index '<title>(.*)</title>' data/feed.xml | \
         tail -n 1)

      # removendo as tags 'title' do início e fim
      tmp_title=${tmp_title#*>}
      tmp_title=${tmp_title%<*}
   }

   echo "$tmp_title"
}

#TODO:
# - filtrar ~título~, texto e link
# - organizar as informações
# - traduzir as codificações html
# - enviar a notícia para o telegram

main() {
   get_news
}

main "$@"
