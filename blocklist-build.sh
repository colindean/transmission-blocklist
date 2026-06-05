#!/usr/bin/env bash

: "${NO_CACHE:-}"

set -e -o pipefail

get_gz_urls() {
  echo 'https://mirror.codebucket.de/transmission/blocklist.p2p.gz'
  curl -s https://www.iblocklist.com/lists.json \
  | jq --raw-output --from-file filter.jq \
  | awk 'length($0) > 2 { print "http://list.iblocklist.com/?fileformat=p2p&archiveformat=gz&list=" $0 }'
}

get_zip_urls() {
    echo 'https://raw.githubusercontent.com/waelisa/Best-blocklist/main/wael.list.p2p.zip'
}

get_plaintext_urls() {
  #echo 'https://mirror.codebucket.de/transmission/blocklist.p2p'
  # https://github.com/Naunter/BT_BlockLists/blob/913f850400c34839e784b91c4e21a97743058b41/url.txt
  echo <<-HERE
    https://reputation.alienvault.com/reputation.generic
    https://www.binarydefense.com/banlist.txt
    https://lists.blocklist.de/lists/all.txt
    https://iplists.firehol.org/files/bruteforceblocker.ipset
    https://cinsscore.com/list/ci-badguys.txt
    https://iplists.firehol.org/files/cruzit_web_attacks.ipset
    https://www.darklist.de/raw.php
    https://rules.emergingthreats.net/blockrules/compromised-ips.txt
    https://feodotracker.abuse.ch/downloads/ipblocklist.txt
    https://iplists.firehol.org/files/nixspam.ipset
    https://sslbl.abuse.ch/blacklist/sslipblacklist.txt
    https://pgl.yoyo.org/adservers/iplist.php?ipformat=plain&showintro=0&mimetype=plaintext
HERE
}

if command -v gzcat > /dev/null; then
  gzcat="gzcat"
elif command -v zcat > /dev/null; then
  gzcat="zcat"
else
  gzcat="gunzip -cd"
fi

# Use aria2c if available for ~300% speedup, mostly from parallel downloading
if [ -z "${NO_CACHE}" ] && [ -n "$(command -v aria2c)" ]; then
  # however, aria2c can't output to stdout, so we have to write to a cache directory
  CACHE=$(mktemp -d cache-XXXXXX)
  mkdir -p "${CACHE}"

  get_gz_urls |
    aria2c \
      --input-file=- \
      --dir="${CACHE}" \
      --optimize-concurrent-downloads=true \
      --stderr \
      --max-connection-per-server="$(nproc)"

  get_zip_urls |
    aria2c \
      --input-file=- \
      --dir="${CACHE}" \
      --optimize-concurrent-downloads=true \
      --stderr \
      --max-connection-per-server="$(nproc)"

  # and then rely on gunzip to output sequentially
  gunzip --stdout "${CACHE}"/* |
    grep -E -v '^#' |
    gzip -1 > blocklist.gz
  # and cleanup afterward
  rm -rf "${CACHE}"

  get_plaintext_urls |
    aria2c \
      --input-file=- \
      --dir="${CACHE}" \
      --optimize-concurrent-downloads=true \
      --stderr \
      --max-connection-per-server="$(nproc)"

  # and then rely on cat to output sequentially
  cat "${CACHE}"/* |
  grep -E -v '^#' |
  gzip -1 >> blocklist.gz
  # and cleanup afterward
  rm -rf "${CACHE}"

else

  get_gz_urls |
    xargs wget -O - |
    gunzip |
    grep -E -v '^#' |
    gzip -1 > blocklist.gz

  get_zip_urls |
    xargs wget -O - |
    ${gzcat} |
    grep -E -v '^#' |
    gzip -1 >> blocklist.gz

  get_plaintext_urls |
    xargs wget -O - |
    grep -E -v '^#' |
    gzip -1 >> blocklist.gz

fi

mv blocklist.gz undeduped.gz

${gzcat} undeduped.gz | sort --unique | gzip -9 > blocklist.gz
rm undeduped.gz
