#!/bin/sh
: "${NO_CACHE:-}"

get_gz_urls() {
  curl -s https://www.iblocklist.com/lists.json \
  | jq --raw-output --from-file filter.jq \
  | awk 'length($0) > 2 { print "http://list.iblocklist.com/?fileformat=p2p&archiveformat=gz&list=" $0 }'
}

get_plaintext_urls() {
  echo 'https://mirror.codebucket.de/transmission/blocklist.p2p'
  echo 'https://raw.githubusercontent.com/waelisa/Best-blocklist/main/wael.list.p2p'
}

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

  get_plaintext_urls |
    xargs wget -O - |
    grep -E -v '^#' |
    gzip -1 >> blocklist.gz
    
fi

mv blocklist.gz undeduped.gz
zcat undeduped.gz | sort --unique | gzip -9 > blocklist.gz
