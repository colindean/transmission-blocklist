#!/usr/bin/env bash

set -eux -o pipefail

CURRENT_FILE="${1:-blocklist.gz}"
LATEST_REPO="${GITHUB_ACTION_REPOSITORY:-${GITHUB_REPOSITORY}}"
LATEST_FILE="blocklist-latest.gz"

function build_latest_release_url() {
    echo "${GITHUB_SERVER_URL}/${LATEST_REPO}/releases/latest/download/blocklist.gz"
}

function get_previous() {
    curl -sSL -o "${LATEST_FILE}" "$(build_latest_release_url)"
}

function is_latest_same_as_current() {
    zdiff --brief --speed-large-files --suppress-common-lines --suppress-blank-empty \
      --ignore-case --ignore-tab-expansion --ignore-trailing-space --ignore-all-space --ignore-blank-lines \
      --label=latest --label=current \
      "${LATEST_FILE}" "${CURRENT_FILE}"
}

get_previous && !is_latest_same_as_current
