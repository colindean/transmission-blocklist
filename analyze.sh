#!/usr/bin/env bash

set -e -o pipefail

log() {
    >&2 echo "${*}"
}
die() {
    log "${@}"
    exit 1
}
range_count() {
    zcat "${blocklist}" | wc -l
}

blocklist="${1:-blocklist.gz}"

if [ ! -f "${blocklist}" ]; then
    die "Blocklist path ${blocklist} doesn't exist."
fi

LANG=en_US.utf8
LC_ALL=en_US.utf8

jq -n -c -M -S \
  --arg range_count "$(printf "%'d" $(range_count) | tr ',' ' ')" \
  '{range_count: $range_count}'
