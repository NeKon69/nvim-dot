#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/generate_all_skills.sh [options]

Options:
  --depth <n>          API recursion depth (default: 4)
  --max-items <n>      Max API items per skill (default: 200)
  --limit <n>          Generate at most N plugins (for testing)
  --only <plugin-id>   Generate only one plugin id (owner/repo)
  --dry-run            Show what would be generated
  --help               Show this help

Example:
  scripts/generate_all_skills.sh --limit 5
EOF
}

DEPTH="4"
MAX_ITEMS="200"
LIMIT=""
ONLY=""
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --depth) DEPTH="${2:-}"; shift 2 ;;
    --max-items) MAX_ITEMS="${2:-}"; shift 2 ;;
    --limit) LIMIT="${2:-}"; shift 2 ;;
    --only) ONLY="${2:-}"; shift 2 ;;
    --dry-run) DRY_RUN="1"; shift ;;
    --help|-h) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage >&2; exit 1 ;;
  esac
done

if [[ ! "$DEPTH" =~ ^[0-9]+$ || ! "$MAX_ITEMS" =~ ^[0-9]+$ ]]; then
  echo "Error: --depth and --max-items must be positive integers." >&2
  exit 1
fi
if [[ -n "$LIMIT" && ! "$LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Error: --limit must be a positive integer." >&2
  exit 1
fi

ROOT_DIR="$(pwd)"
LAZY_DIR="${HOME}/.local/share/nvim/lazy"
GEN_ONE="${ROOT_DIR}/scripts/generate_skill.sh"

if [[ ! -x "$GEN_ONE" ]]; then
  echo "Error: scripts/generate_skill.sh is missing or not executable." >&2
  exit 1
fi

if [[ ! -d "$ROOT_DIR/lua/plugins" ]]; then
  echo "Error: lua/plugins directory not found." >&2
  exit 1
fi

if [[ ! -d "$LAZY_DIR" ]]; then
  echo "Error: lazy plugin dir not found: $LAZY_DIR" >&2
  exit 1
fi

collect_plugin_ids() {
  rg -No --no-filename --pcre2 "(?<=['\"])[A-Za-z0-9][A-Za-z0-9_.-]*/[A-Za-z0-9][A-Za-z0-9_.-]*(?=['\"])" "$ROOT_DIR/lua/plugins" \
    | sort -u
}

is_installed_plugin() {
  local plugin_id="$1"
  local repo="${plugin_id##*/}"
  local dir="${LAZY_DIR}/${repo}"
  [[ -d "$dir" ]] && { [[ -d "${dir}/lua" ]] || [[ -f "${dir}/README.md" ]]; }
}

module_candidates_for_repo() {
  local repo="$1"
  local dir="${LAZY_DIR}/${repo}"
  local base="${repo%.nvim}"

  # Heuristics first.
  printf '%s\n' "$base"
  printf '%s\n' "${base#nvim-}"
  printf '%s\n' "${base%-nvim}"
  printf '%s\n' "$(printf '%s' "$base" | tr '-' '_')"

  # Add discovered top-level Lua module names.
  if [[ -d "${dir}/lua" ]]; then
    find "${dir}/lua" -maxdepth 1 -mindepth 1 \( -type d -o -type f -name '*.lua' \) \
      | sed -E 's#.*/lua/##; s#\.lua$##' \
      | rg -v '^(plugin|after|doc|tests?|spec|lua)$' || true
  fi
}

module_works_for_plugin() {
  local plugin_id="$1"
  local module="$2"
  local repo="${plugin_id##*/}"
  local tmp_lua tmp_init tmp_ok
  tmp_lua="$(mktemp --suffix=.lua)"
  tmp_init="$(mktemp --suffix=.lua)"
  tmp_ok="$(mktemp)"

  cat > "$tmp_init" <<'LUA'
local plugin_repo = assert(vim.env.SKILL_PLUGIN_REPO, "SKILL_PLUGIN_REPO is required")
local plugin_dir = vim.fn.stdpath("data") .. "/lazy/" .. plugin_repo
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
require("lazy").setup({
  { name = plugin_repo, dir = plugin_dir, lazy = true },
}, {
  rocks = { enabled = false },
  defaults = { lazy = true },
})
LUA

  cat > "$tmp_lua" <<'LUA'
local plugin_repo = assert(vim.env.SKILL_PLUGIN_REPO, "SKILL_PLUGIN_REPO is required")
local module_name = assert(vim.env.SKILL_TEST_MODULE, "SKILL_TEST_MODULE is required")
local ok_file = assert(vim.env.SKILL_OK_FILE, "SKILL_OK_FILE is required")

local lazy = require("lazy")
lazy.load({ plugins = { plugin_repo } })
local ok = pcall(require, module_name)
if ok then
  vim.fn.writefile({ "ok" }, ok_file)
end
LUA

  XDG_STATE_HOME="/tmp/nvim-state" \
  XDG_CACHE_HOME="/tmp/nvim-cache" \
  SKILL_PLUGIN_REPO="$repo" \
  SKILL_TEST_MODULE="$module" \
  SKILL_OK_FILE="$tmp_ok" \
  nvim --headless --cmd "let g:headless = 1" -u "$tmp_init" "+lua dofile('$tmp_lua')" +qa \
    >/dev/null 2>&1 || true

  local ok=1
  if [[ -s "$tmp_ok" ]]; then
    ok=0
  fi

  rm -f "$tmp_lua" "$tmp_init" "$tmp_ok"
  return "$ok"
}

discover_module() {
  local plugin_id="$1"
  local repo="${plugin_id##*/}"
  local candidate

  # Try deterministic candidates in order, unique.
  while IFS= read -r candidate; do
    [[ -z "$candidate" ]] && continue
    if module_works_for_plugin "$plugin_id" "$candidate"; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done < <(module_candidates_for_repo "$repo" | awk '!seen[$0]++')

  return 1
}

generated=0
skipped_missing=0
skipped_module=0
failed=0

mapfile -t all_plugins < <(collect_plugin_ids)
if [[ -n "$ONLY" ]]; then
  all_plugins=("$ONLY")
fi

for plugin_id in "${all_plugins[@]}"; do
  [[ -z "$plugin_id" ]] && continue

  if [[ -n "$LIMIT" && "$generated" -ge "$LIMIT" ]]; then
    break
  fi

  if ! is_installed_plugin "$plugin_id"; then
    echo "skip(not-installed): $plugin_id"
    skipped_missing=$((skipped_missing + 1))
    continue
  fi

  if ! module="$(discover_module "$plugin_id")"; then
    echo "skip(no-module): $plugin_id"
    skipped_module=$((skipped_module + 1))
    continue
  fi

  skill_name="${plugin_id##*/}"
  cmd=( "$GEN_ONE"
    --plugin "$plugin_id"
    --module "$module"
    --skill-name "$skill_name"
    --depth "$DEPTH"
    --max-items "$MAX_ITEMS"
  )

  echo "gen: plugin=$plugin_id module=$module skill=$skill_name"
  if [[ "$DRY_RUN" == "1" ]]; then
    generated=$((generated + 1))
    continue
  fi

  if "${cmd[@]}" >/dev/null 2>&1; then
    generated=$((generated + 1))
  else
    echo "fail: $plugin_id" >&2
    failed=$((failed + 1))
  fi
done

echo "summary: generated=$generated skipped_not_installed=$skipped_missing skipped_no_module=$skipped_module failed=$failed"

if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
