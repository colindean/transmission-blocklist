#!/usr/bin/env bash

: "${NO_CACHE:-}"

set -e -o pipefail

log() {
  >&2 echo "${*}"
}

# In GitHub Actions, warnings and errors also show up as annotations on the run.
warn() {
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    log "::warning::${*}"
  else
    log "WARNING: ${*}"
  fi
}

die() {
  if [ -n "${GITHUB_ACTIONS:-}" ]; then
    log "::error::${*}"
  else
    log "ERROR: ${*}"
  fi
  exit 1
}

get_gz_urls() {
  echo 'https://mirror.codebucket.de/transmission/blocklist.p2p.gz'
  curl -sS --fail https://www.iblocklist.com/lists.json \
  | jq --raw-output --from-file filter.jq \
  | awk 'length($0) > 2 { print "http://list.iblocklist.com/?fileformat=p2p&archiveformat=gz&list=" $0 }' \
  || warn "Failed to retrieve the iblocklist.com list index; skipping iblocklist.com lists"
}

get_zip_urls() {
    echo 'https://raw.githubusercontent.com/waelisa/Best-blocklist/main/wael.list.p2p.zip'
}

get_plaintext_urls() {
  #echo 'https://mirror.codebucket.de/transmission/blocklist.p2p'
  # https://github.com/Naunter/BT_BlockLists/blob/913f850400c34839e784b91c4e21a97743058b41/url.txt
  cat <<HERE
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

# Downloads each URL read from stdin into the directory ${1}, saving them as
# 1, 2, 3, ... in input order. The URLs are kept in ${1}/.urls so that
# print_entries can tell which file came from where.
# A failed download doesn't stop the build; print_entries skips it.
fetch_into() {
  local dir="${1}" n=0 url
  mkdir -p "${dir}"
  awk 'NF' > "${dir}/.urls"

  # Use aria2c if available for ~300% speedup, mostly from parallel downloading
  if [ -z "${NO_CACHE}" ] && [ -n "$(command -v aria2c)" ]; then
    awk '{ print; print "  out=" NR }' "${dir}/.urls" |
      aria2c \
        --input-file=- \
        --dir="${dir}" \
        --optimize-concurrent-downloads=true \
        --stderr \
        --max-connection-per-server="$(nproc)" \
    || log "aria2c failed to download some files; continuing with the rest"
  else
    while read -r url; do
      n=$((n + 1))
      wget -O "${dir}/${n}" "${url}" || rm -f "${dir}/${n}"
    done < "${dir}/.urls"
  fi
}

# Prints the entries of each file fetched into the directory ${1}.
# ${2} is the type the files should be: "compressed" (gzip, or a zip file
# with a single entry) or "plaintext". Files that failed to download or
# aren't of that type are skipped with a warning.
print_entries() {
  local dir="${1}" type="${2}" n=0 url file error
  while read -r url; do
    n=$((n + 1))
    file="${dir}/${n}"
    if [ ! -s "${file}" ] || [ -e "${file}.aria2" ]; then
      warn "Skipping ${url}: download failed or is incomplete"
      continue
    fi
    case "${type}" in
      compressed)
        if error=$(gzip --test "${file}" 2>&1); then
          gzip --decompress --stdout "${file}"
        else
          warn "Skipping ${url}: not a valid gzip or zip file (${error##*: })"
        fi
        ;;
      plaintext)
        case "$(file --brief --mime-type "${file}")" in
          text/html | text/xml) ;;
          text/*)
            cat "${file}"
            continue
            ;;
        esac
        warn "Skipping ${url}: expected plain text but got $(file --brief "${file}")"
        ;;
    esac
  done < "${dir}/.urls"
}

if command -v gzcat > /dev/null; then
  gzcat="gzcat"
elif command -v zcat > /dev/null; then
  gzcat="zcat"
else
  gzcat="gunzip -cd"
fi

# aria2c can't output to stdout, and each file needs checking before use
# anyway, so everything is downloaded to a cache directory first.
CACHE=$(mktemp -d cache-XXXXXX)
trap 'rm -rf "${CACHE}"' EXIT

{ get_gz_urls; get_zip_urls; } | fetch_into "${CACHE}/compressed"
get_plaintext_urls | fetch_into "${CACHE}/plaintext"

{
  print_entries "${CACHE}/compressed" compressed
  print_entries "${CACHE}/plaintext" plaintext
} |
  { grep -E -v '^#' || true; } |
  gzip -1 > undeduped.gz

${gzcat} undeduped.gz | sort --unique | gzip -9 > blocklist.gz
rm undeduped.gz

if [ "$(${gzcat} blocklist.gz | wc -l)" -eq 0 ]; then
  die "No usable blocklist entries were retrieved; refusing to build an empty blocklist"
fi
