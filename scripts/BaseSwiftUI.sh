#!/bin/sh

set -eu

REPOSITORY_URL="https://github.com/VuTheAnhMatech/BaseSwiftUI.git"
BRANCH="main"
SOURCE_MODE=remote
LOCAL_TEMPLATE=""

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

case "${1:-}" in
  --local)
    [ "$#" -eq 2 ] || fail "Usage: BaseSwiftUI.sh --local /path/to/BaseSwiftUI"
    SOURCE_MODE=local
    LOCAL_TEMPLATE=$2
    ;;
  --remote)
    [ "$#" -eq 1 ] || fail "Usage: BaseSwiftUI.sh --remote"
    SOURCE_MODE=remote
    ;;
  --help|-h)
    printf '%s\n' \
      'Run from the destination project folder.' \
      'Default: download the latest pushed GitHub main on every run (internet required).' \
      '--local /path/to/BaseSwiftUI: use that checkout committed HEAD (ignores uncommitted files).' \
      '--remote: same as the default; never falls back to a local checkout.' \
      'The project bootstrap may replace an existing Xcode project in the destination.'
    exit 0
    ;;
  "") [ "$#" -eq 0 ] || fail "Unknown arguments; use --help." ;;
  *) fail "Unknown arguments; use --help." ;;
esac

# The downstream bootstrap can replace an existing project. Never target the source.
if [ -f scripts/create_project.sh ] && [ -d BaseSwiftUI.xcodeproj ]; then
  fail "Run from a destination outside the BaseSwiftUI source checkout."
fi

command -v git >/dev/null 2>&1 || fail "Máy chưa có Git."
command -v tar >/dev/null 2>&1 || fail "Máy chưa có tar."

TEMP_ROOT=$(mktemp -d "${TMPDIR:-/tmp}/BaseSwiftUI-template.XXXXXX")
trap 'rm -rf "$TEMP_ROOT"' 0
trap 'exit 130' INT
trap 'exit 143' HUP TERM
TEMPLATE_ROOT="$TEMP_ROOT/BaseSwiftUI"

if [ "$SOURCE_MODE" = local ]; then
  LOCAL_TEMPLATE=$(CDPATH= cd -- "$LOCAL_TEMPLATE" && pwd -P) || fail "Invalid local template path."
  [ -f "$LOCAL_TEMPLATE/scripts/create_project.sh" ] && \
    [ -d "$LOCAL_TEMPLATE/BaseSwiftUI.xcodeproj" ] || fail "Not a BaseSwiftUI template checkout."
  REPO_ROOT=$(git -C "$LOCAL_TEMPLATE" rev-parse --show-toplevel)
  REPO_ROOT=$(CDPATH= cd -- "$REPO_ROOT" && pwd -P)
  [ "$REPO_ROOT" = "$LOCAL_TEMPLATE" ] || fail "Local template must be the Git repository root."
  # Refuse to run the destructive project bootstrap in the source checkout.
  DESTINATION_ROOT=$(pwd -P)
  case "$DESTINATION_ROOT/" in
    "$LOCAL_TEMPLATE/"*) fail "Run from a destination outside the BaseSwiftUI source checkout." ;;
  esac
  TEMPLATE_COMMIT=$(git -C "$LOCAL_TEMPLATE" rev-parse HEAD)
  printf 'Using committed local BaseSwiftUI %s from %s.\n' "$TEMPLATE_COMMIT" "$LOCAL_TEMPLATE"
  mkdir -p "$TEMPLATE_ROOT"
  git -C "$LOCAL_TEMPLATE" archive --format=tar --output "$TEMP_ROOT/template.tar" "$TEMPLATE_COMMIT"
  tar -xf "$TEMP_ROOT/template.tar" -C "$TEMPLATE_ROOT"
else
  printf 'Downloading BaseSwiftUI %s from GitHub...\n' "$BRANCH"
  git clone --quiet --depth 1 --single-branch --no-tags --branch "$BRANCH" \
    "$REPOSITORY_URL" "$TEMPLATE_ROOT"
  TEMPLATE_COMMIT=$(git -C "$TEMPLATE_ROOT" rev-parse HEAD)
  printf 'Using BaseSwiftUI commit %s.\n' "$TEMPLATE_COMMIT"
fi

BOOTSTRAP_SCRIPT="$TEMPLATE_ROOT/scripts/create_project.sh"
[ -f "$BOOTSTRAP_SCRIPT" ] || fail "Template does not contain scripts/create_project.sh."
VALIDATOR="$TEMPLATE_ROOT/.codex/skills/baseswiftui-agent-maintenance/scripts/validate_agent_setup.py"
if [ -f "$VALIDATOR" ]; then
  command -v python3 >/dev/null 2>&1 || fail "python3 is required to validate bundled agent guidance."
  python3 -B "$VALIDATOR"
fi

sh "$BOOTSTRAP_SCRIPT"
