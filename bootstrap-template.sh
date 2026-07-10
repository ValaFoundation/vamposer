#!/usr/bin/env bash
set -euo pipefail

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

OLD_SLUG="vala-library-template"
OLD_DEP_NAME="vala_library_template"
OLD_GH_REPO="ValaFoundation/library-template"
OLD_TITLE="Vala library template"

to_slug() {
  local input="$1"
  local slug
  slug="$(echo "$input" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//; s/-{2,}/-/g')"
  printf '%s' "$slug"
}

replace_all() {
  local old="$1"
  local new="$2"
  shift 2
  local f
  for f in "$@"; do
    [ -f "$f" ] || continue
    sed -i "s|${old}|${new}|g" "$f"
  done
}

remove_marked_block() {
  local file="$1"
  local start_marker="$2"
  local end_marker="$3"

  [ -f "$file" ] || return 0
  if ! grep -Fq "$start_marker" "$file"; then
    return 0
  fi

  awk -v start="$start_marker" -v end="$end_marker" '
    index($0, start) { skip = 1; next }
    index($0, end) { skip = 0; next }
    !skip { print }
  ' "$file" > "$file.tmp"

  mv "$file.tmp" "$file"
}

if [ ! -f "meson.build" ]; then
  echo -e "${RED}[Error] Run this script from repository root.${NC}"
  exit 1
fi

RAW_NAME="${1:-$(basename "$PWD")}"
NEW_SLUG="$(to_slug "$RAW_NAME")"

if [ -z "$NEW_SLUG" ]; then
  echo -e "${RED}[Error] Unable to derive valid project name from '${RAW_NAME}'.${NC}"
  exit 1
fi

NEW_DEP_NAME="${NEW_SLUG//-/_}"
NEW_TITLE="${NEW_SLUG//-/ }"

REMOTE_URL="$(git remote get-url origin 2>/dev/null || true)"
NEW_GH_REPO=""
NEW_REPO_URL=""

if echo "$REMOTE_URL" | grep -qE '^https://github\.com/[^/]+/[^/]+(\.git)?$'; then
  NEW_GH_REPO="$(echo "$REMOTE_URL" | sed -E 's|https://github.com/([^/]+/[^/.]+)(\.git)?$|\1|')"
  NEW_REPO_URL="https://github.com/${NEW_GH_REPO}.git"
elif echo "$REMOTE_URL" | grep -qE '^git@github\.com:[^/]+/[^/]+(\.git)?$'; then
  NEW_GH_REPO="$(echo "$REMOTE_URL" | sed -E 's|git@github.com:([^/]+/[^/.]+)(\.git)?$|\1|')"
  NEW_REPO_URL="https://github.com/${NEW_GH_REPO}.git"
else
  NEW_GH_REPO="OWNER/${NEW_SLUG}"
  NEW_REPO_URL="https://github.com/${NEW_GH_REPO}.git"
fi

FILES=(
  "README.md"
  "meson.build"
  "src/meson.build"
  "tests/meson.build"
  ".github/ISSUE_TEMPLATE/config.yml"
  "init.sh"
  "init-local-vapi.sh"
)

replace_all "$OLD_SLUG" "$NEW_SLUG" "${FILES[@]}"
replace_all "$OLD_DEP_NAME" "$NEW_DEP_NAME" "${FILES[@]}"
replace_all "$OLD_GH_REPO" "$NEW_GH_REPO" "${FILES[@]}"
replace_all "$OLD_TITLE" "$NEW_TITLE" "README.md"
remove_marked_block "README.md" "<!-- TEMPLATE_BOOTSTRAP_START -->" "<!-- TEMPLATE_BOOTSTRAP_END -->"

if grep -q "project('${OLD_SLUG}'" meson.build; then
  sed -i "s|project('${OLD_SLUG}'|project('${NEW_SLUG}'|" meson.build
fi

chmod +x bootstrap-template.sh init.sh init-local-vapi.sh

echo -e "${GREEN}[Done] Template bootstrap complete.${NC}"
echo -e ""
echo -e "Project slug      : ${NEW_SLUG}"
echo -e "Dependency name   : ${NEW_DEP_NAME}"
echo -e "Repository URL    : ${NEW_REPO_URL}"
echo -e ""
echo -e "Next steps:"
echo -e "  1) Review README.md"
echo -e "  2) Run: meson setup builddir && meson compile -C builddir"
echo -e "  3) Run: meson test -C builddir"

SCRIPT_PATH="${BASH_SOURCE[0]:-}"
if [ "${KEEP_SCRIPT:-0}" != "1" ] && [ -n "${SCRIPT_PATH}" ] && [ -f "${SCRIPT_PATH}" ]; then
  rm -f -- "${SCRIPT_PATH}" || true
fi
