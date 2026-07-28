#!/bin/sh

set -eu

TEMPLATE_NAME="BaseSwiftUI"
TEMPLATE_SKILL_PREFIX="baseswiftui"
BUNDLE_IDENTIFIER="com.emoji.ai.maker.stickermaker"
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
TEMPLATE_ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
DESTINATION_ROOT=$(pwd -P)
PROJECT_NAME=$(basename "$DESTINATION_ROOT")

fail() {
  printf 'Error: %s\n' "$1" >&2
  exit 1
}

case "$PROJECT_NAME" in
  ""|[0-9]*|*[!A-Za-z0-9_]*)
    fail "Tên thư mục project phải dùng chữ, số hoặc dấu gạch dưới và không được bắt đầu bằng số."
    ;;
esac

if [ "$DESTINATION_ROOT" = "$TEMPLATE_ROOT" ]; then
  fail "Hãy chạy script từ thư mục project mới, không chạy ngay trong template."
fi

case "$DESTINATION_ROOT/" in
  "$TEMPLATE_ROOT"/*)
    fail "Thư mục project mới không được nằm bên trong template."
    ;;
esac

if [ ! -d "$TEMPLATE_ROOT/$TEMPLATE_NAME.xcodeproj" ] || [ ! -d "$TEMPLATE_ROOT/$TEMPLATE_NAME" ]; then
  fail "Không tìm thấy cấu trúc template tại $TEMPLATE_ROOT."
fi

EXISTING_ENTRY=$(find "$DESTINATION_ROOT" -mindepth 1 -maxdepth 1 \
  ! -name '.git' \
  ! -name '.DS_Store' \
  -print -quit)

command -v rsync >/dev/null 2>&1 || fail "Máy chưa có rsync."
command -v perl >/dev/null 2>&1 || fail "Máy chưa có perl."
command -v ruby >/dev/null 2>&1 || fail "Máy chưa có Ruby."
command -v pod >/dev/null 2>&1 || fail "Máy chưa có CocoaPods. Hãy cài bằng: sudo gem install cocoapods"

if [ -n "$EXISTING_ENTRY" ]; then
  EXISTING_XCODE_PROJECT=$(find "$DESTINATION_ROOT" -mindepth 1 -maxdepth 1 \
    -type d -name '*.xcodeproj' -print -quit)

  if [ -z "$EXISTING_XCODE_PROJECT" ]; then
    fail "Thư mục không rỗng và không chứa project Xcode ở cấp ngoài cùng. Dừng để tránh xóa nhầm dữ liệu."
  fi

  printf 'Removing the existing project from %s...\n' "$DESTINATION_ROOT"
  find "$DESTINATION_ROOT" -mindepth 1 -maxdepth 1 \
    ! -name '.git' \
    ! -name '.DS_Store' \
    -exec rm -rf {} +
fi

printf 'Creating %s from %s...\n' "$PROJECT_NAME" "$TEMPLATE_ROOT"

rsync -a \
  --exclude '.git/' \
  --exclude '.DS_Store' \
  --exclude 'Pods/' \
  --exclude 'Podfile.lock' \
  --exclude "$TEMPLATE_NAME.xcworkspace/" \
  --exclude 'xcuserdata/' \
  --exclude 'DerivedData/' \
  --exclude 'build/' \
  --exclude '.team-tools/.env' \
  "$TEMPLATE_ROOT/" "$DESTINATION_ROOT/"

mv "$DESTINATION_ROOT/$TEMPLATE_NAME" "$DESTINATION_ROOT/$PROJECT_NAME"
mv "$DESTINATION_ROOT/$TEMPLATE_NAME.xcodeproj" "$DESTINATION_ROOT/$PROJECT_NAME.xcodeproj"

OLD_SCHEME="$DESTINATION_ROOT/$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes/$TEMPLATE_NAME.xcscheme"
NEW_SCHEME="$DESTINATION_ROOT/$PROJECT_NAME.xcodeproj/xcshareddata/xcschemes/$PROJECT_NAME.xcscheme"
if [ -f "$OLD_SCHEME" ]; then
  mv "$OLD_SCHEME" "$NEW_SCHEME"
fi

OLD_APP_FILE="$DESTINATION_ROOT/$PROJECT_NAME/${TEMPLATE_NAME}App.swift"
NEW_APP_FILE="$DESTINATION_ROOT/$PROJECT_NAME/${PROJECT_NAME}App.swift"
if [ -f "$OLD_APP_FILE" ]; then
  mv "$OLD_APP_FILE" "$NEW_APP_FILE"
fi

PROJECT_SKILL_PREFIX=$(printf '%s' "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | tr '_' '-')

for skill_dir in "$DESTINATION_ROOT/.codex/skills/$TEMPLATE_SKILL_PREFIX-"*; do
  [ -d "$skill_dir" ] || continue
  skill_name=$(basename "$skill_dir")
  skill_suffix=${skill_name#"$TEMPLATE_SKILL_PREFIX-"}
  mv "$skill_dir" "$DESTINATION_ROOT/.codex/skills/$PROJECT_SKILL_PREFIX-$skill_suffix"
done

export TEMPLATE_NAME PROJECT_NAME TEMPLATE_SKILL_PREFIX PROJECT_SKILL_PREFIX
find "$DESTINATION_ROOT" \
  -path "$DESTINATION_ROOT/.git" -prune -o \
  -path "$DESTINATION_ROOT/Pods" -prune -o \
  -name 'BaseSwiftUI.sh' -prune -o \
  -type f \( \
    -name '*.swift' -o \
    -name '*.rb' -o \
    -name '*.md' -o \
    -name '*.plist' -o \
    -name '*.pbxproj' -o \
    -name '*.xcscheme' -o \
    -name '*.json' -o \
    -name '*.yaml' -o \
    -name '*.yml' -o \
    -name '*.xcconfig' -o \
    -name '*.sh' -o \
    -name 'Podfile' \
  \) -exec perl -pi -e 's/\Q$ENV{TEMPLATE_NAME}\E/$ENV{PROJECT_NAME}/g' {} +

find "$DESTINATION_ROOT" \
  -path "$DESTINATION_ROOT/.git" -prune -o \
  -path "$DESTINATION_ROOT/Pods" -prune -o \
  -name 'BaseSwiftUI.sh' -prune -o \
  -type f \( \
    -name '*.swift' -o \
    -name '*.rb' -o \
    -name '*.md' -o \
    -name '*.plist' -o \
    -name '*.pbxproj' -o \
    -name '*.xcscheme' -o \
    -name '*.json' -o \
    -name '*.yaml' -o \
    -name '*.yml' -o \
    -name '*.xcconfig' -o \
    -name '*.sh' -o \
    -name 'Podfile' \
  \) -exec perl -pi -e 's/\Q$ENV{TEMPLATE_SKILL_PREFIX}\E/$ENV{PROJECT_SKILL_PREFIX}/g' {} +

cd "$DESTINATION_ROOT"
ruby scripts/generate_project.rb
pod install

if [ ! -d "$PROJECT_NAME.xcworkspace" ]; then
  fail "CocoaPods không tạo được $PROJECT_NAME.xcworkspace."
fi

printf '\nCreated successfully.\n'
printf 'Project: %s\n' "$PROJECT_NAME"
printf 'Bundle ID: %s\n' "$BUNDLE_IDENTIFIER"
printf 'Open: %s.xcworkspace\n' "$PROJECT_NAME"
