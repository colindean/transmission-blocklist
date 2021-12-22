#!/bin/sh
: "${NO_CACHE:-}"
# Use aria2c if available for ~300% speedup, mostly from parallel downloading
if [ -z "${NO_CACHE}" ] && [ -n "$(command -v aria2c)" ]; then
  # however, aria2c can't output to stdout, so we have to write to a cache directory
  CACHE=$(mktemp -d cache-XXXXXX)
  mkdir -p "${CACHE}"

  curl -s https://www.iblocklist.com/lists.json |
    jq --raw-output --from-file filter.jq |
    awk 'length($0) > 2 { print "http://list.iblocklist.com/?fileformat=p2p&archiveformat=gz&list=" $0 }' |
    aria2c \
      --input-file=- \
      --dir="${CACHE}" \
      --optimize-concurrent-downloads=true \
      --stderr \
      --max-connection-per-server="$(nproc)"

  # and then rely on gunzip to output sequentially
  gunzip --stdout "${CACHE}"/* |
    grep -E -v '^#' |
    gzip >blocklist.gz
  # and cleanup afterward
  rm -rf "${CACHE}"

else

  curl -s https://www.iblocklist.com/lists.json |
    jq --raw-output --from-file filter.jq |
    awk 'length($0) > 2 { print "http://list.iblocklist.com/?fileformat=p2p&archiveformat=gz&list=" $0 }' |
    xargs wget -O - |
    gunzip |
    grep -E -v '^#' |
    gzip >blocklist.gz
fi
