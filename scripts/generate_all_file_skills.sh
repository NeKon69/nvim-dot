#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/generate_all_file_skills.sh [options]

Options:
  --roots <paths>         Comma-separated roots to scan (default: lua/user,lua/plugins)
  --limit <n>             Generate at most N files
  --only <pattern>        Include only file paths containing this substring
  --force                 Overwrite existing skill files
  --dry-run               Show commands without running generation
  --help                  Show this help

Examples:
  scripts/generate_all_file_skills.sh
  scripts/generate_all_file_skills.sh --roots lua/user --dry-run
  scripts/generate_all_file_skills.sh --only project --force
EOF
}

ROOTS_CSV="lua/user,lua/plugins"
LIMIT=""
ONLY=""
FORCE="0"
DRY_RUN="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --roots)
      ROOTS_CSV="${2:-}"
      shift 2
      ;;
    --limit)
      LIMIT="${2:-}"
      shift 2
      ;;
    --only)
      ONLY="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
      shift
      ;;
    --dry-run)
      DRY_RUN="1"
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [[ -n "$LIMIT" && ! "$LIMIT" =~ ^[0-9]+$ ]]; then
  echo "Error: --limit must be a positive integer." >&2
  exit 1
fi

GEN_ONE="./scripts/generate_file_skill.sh"
if [[ ! -x "$GEN_ONE" ]]; then
  echo "Error: scripts/generate_file_skill.sh is missing or not executable." >&2
  exit 1
fi

IFS=',' read -r -a ROOTS <<<"$ROOTS_CSV"
for root in "${ROOTS[@]}"; do
  if [[ ! -d "$root" ]]; then
    echo "Error: scan root not found: $root" >&2
    exit 1
  fi
done

mapfile -t LUA_FILES < <(rg --files "${ROOTS[@]}" -g '*.lua' | sort)

generated=0
skipped=0
failed=0

for file in "${LUA_FILES[@]}"; do
  [[ -z "$file" ]] && continue

  if [[ -n "$LIMIT" && "$generated" -ge "$LIMIT" ]]; then
    break
  fi

  if [[ -n "$ONLY" && "$file" != *"$ONLY"* ]]; then
    skipped=$((skipped + 1))
    continue
  fi

  kind=""
  case "$file" in
    lua/user/*) kind="user" ;;
    lua/plugins/*) kind="plugin" ;;
    *)
      echo "skip(kind): $file"
      skipped=$((skipped + 1))
      continue
      ;;
  esac

  if [[ "$kind" == "user" ]]; then
    rel="${file#lua/user/}"
  else
    rel="${file#lua/plugins/}"
  fi
  rel="${rel%.lua}"
  rel="${rel//\//.}"
  skill_name="${kind}.${rel}"

  cmd=(
    "$GEN_ONE"
    --file "$file"
    --kind "$kind"
    --skill-name "$skill_name"
  )
  if [[ "$FORCE" == "1" ]]; then
    cmd+=(--force)
  fi

  if [[ "$DRY_RUN" == "1" ]]; then
    printf 'dry-run:'
    printf ' %q' "${cmd[@]}"
    printf '\n'
    generated=$((generated + 1))
    continue
  fi

  echo "gen: $file -> $skill_name"
  if "${cmd[@]}" >/dev/null 2>&1; then
    generated=$((generated + 1))
  else
    echo "fail: $file" >&2
    failed=$((failed + 1))
  fi
done

echo "summary: generated=$generated skipped=$skipped failed=$failed"
if [[ "$failed" -gt 0 ]]; then
  exit 1
fi
