#! /bin/bash

download() {
  [[ -f "${1}" ]] && return
  wget -O $1 $2
}

download_and_compress() {
  [[ -f "${1}.bz2" ]] && return
  wget -O $1 $2
  bzip2 $1
}

download_synonyms() {
  [[ -f $1.mysql.tar.bz2 ]] && return
  wget -O $1.mysql.tar.bz2 "$2"
  tar xf $1.mysql.tar.bz2 openthesaurus_dump.sql
  gawk -f __mysql2sqlite.sh openthesaurus_dump.sql | sqlite3 $1.sqlite
  rm openthesaurus_dump.sql
  bzip2 $1.sqlite
  python3 openthesaurus_extract_synsets.py $1.sqlite.bz2
}

download_genders() {
  download_and_compress $1 "$2"
  python3 article_xml_to_json.py $1.bz2
}

download_and_compress \
  __words_to_url.json https://www.dwds.de/dwds_static/wb/dwdswb-headwords.json
download_and_compress \
  __words_to_freq.json https://www.dwds.de/lemma/json
download_genders \
  __words_to_gender.xml https://www.dwds.de/dwds_static/wb/dwdswb-headwords.lmf.xml
download_and_compress \
  __words_to_a1_level.json https://www.dwds.de/api/lemma/goethe/A1.json
download_and_compress \
  __words_to_a2_level.json https://www.dwds.de/api/lemma/goethe/A2.json
download_and_compress \
  __words_to_b1_level.json https://www.dwds.de/api/lemma/goethe/B1.json
download \
  __mysql2sqlite.sh https://raw.githubusercontent.com/mysql2sqlite/mysql2sqlite/refs/heads/master/mysql2sqlite
download_synonyms \
  __words_to_synonyms https://www.openthesaurus.de/export/openthesaurus_dump.tar.bz2

