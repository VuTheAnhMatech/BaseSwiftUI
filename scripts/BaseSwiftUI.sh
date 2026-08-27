#!/bin/sh

set -eu

REPOSITORY_URL="https://github.com/VuTheAnhMatech/BaseSwiftUI.git"
BRANCH="main"

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

command -v git >/dev/null 2>&1 || fail "Máy chưa có Git."

TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/BaseSwiftUI-remote.XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' EXIT HUP INT TERM

printf 'Downloading the latest BaseSwiftUI from GitHub...\n'
git clone --quiet --depth 1 --single-branch --no-tags --branch "$BRANCH" \
  "$REPOSITORY_URL" "$TEMP_ROOT/BaseSwiftUI"

TEMPLATE_COMMIT=$(git -C "$TEMP_ROOT/BaseSwiftUI" rev-parse --short HEAD)
printf 'Using BaseSwiftUI commit %s.\n' "$TEMPLATE_COMMIT"

REMOTE_SCRIPT="$TEMP_ROOT/BaseSwiftUI/scripts/create_project.sh"
if [ ! -f "$REMOTE_SCRIPT" ]; then
  fail "Repository không chứa scripts/create_project.sh."
fi

sh "$REMOTE_SCRIPT"
