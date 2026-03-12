#!/usr/bin/env bash

set -euo pipefail

export SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

if [[ ! -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
  curl -s "https://get.sdkman.io" | bash
fi

# shellcheck source=/dev/null
source "$SDKMAN_DIR/bin/sdkman-init.sh"

resolve_latest_temurin() {
  local major_version="$1"

  sdk list java | awk -F'|' -v major_version="$major_version" '
    $0 ~ /[|][[:space:]]*tem[[:space:]]*[|]/ {
      identifier = $6
      gsub(/^[[:space:]]+|[[:space:]]+$/, "", identifier)

      if (identifier ~ ("^" major_version "\\.")) {
        print identifier
        exit
      }
    }
  '
}

install_java_version() {
  local version="$1"

  if [[ -z "$version" ]]; then
    echo "Failed to resolve a Java version to install." >&2
    exit 1
  fi

  printf 'n\n' | sdk install java "$version"
}

temurin_21_version="$(resolve_latest_temurin 21)"
temurin_25_version="$(resolve_latest_temurin 25)"

install_java_version "$temurin_21_version"
install_java_version "$temurin_25_version"
sdk default java "$temurin_25_version"

echo "Installed $temurin_21_version and $temurin_25_version. Default is $temurin_25_version."
