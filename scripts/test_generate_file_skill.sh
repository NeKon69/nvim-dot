#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GEN="${ROOT_DIR}/scripts/generate_file_skill.sh"

if [[ ! -x "$GEN" ]]; then
  echo "error: generator is not executable: $GEN" >&2
  exit 1
fi

TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

mkdir -p "$TMP_DIR/lua/user" "$TMP_DIR/lua/plugins"

cat > "$TMP_DIR/lua/user/example.lua" <<'LUA'
local M = {}

local dep = require("plenary.path")

vim.api.nvim_create_user_command("UserExample", function()
  print("ok")
end, {})

vim.api.nvim_create_autocmd("BufWritePost", {
  pattern = "*.lua",
  callback = function() end,
})

vim.api.nvim_create_autocmd({
  "VimEnter",
  "BufWinEnter",
}, {
  callback = function() end,
})

vim.keymap.set("n", "<leader>ue", function()
  print(dep)
end, { desc = "User Example" })

function M.setup(opts)
  return opts
end

M.run = function(target, cb)
  if cb then
    cb(target)
  end
end

return M
LUA

cat > "$TMP_DIR/lua/plugins/example.lua" <<'LUA'
return {
  {
    "folke/which-key.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    config = function()
      vim.keymap.set("n", "<leader>pk", "<cmd>echo 'plugin'<CR>")
    end,
  },
}
LUA

assert_contains() {
  local needle="$1"
  local file="$2"
  if ! rg -F --quiet -- "$needle" "$file"; then
    echo "assertion failed: missing '$needle' in $file" >&2
    exit 1
  fi
}

# user file generation and extraction checks
(
  cd "$TMP_DIR"
  "$GEN" \
    --file "lua/user/example.lua" \
    --kind user \
    --force \
    >/dev/null
)

USER_SKILL="$TMP_DIR/.agents/skills/user.example/SKILL.md"
[[ -f "$USER_SKILL" ]] || { echo "missing output: $USER_SKILL" >&2; exit 1; }

assert_contains '## Commands (`:`) detected in file' "$USER_SKILL"
assert_contains "require(\"user.example\").setup(opts)" "$USER_SKILL"
assert_contains "require(\"user.example\").run(target, cb)" "$USER_SKILL"
assert_contains ":UserExample" "$USER_SKILL"
assert_contains "vim.keymap.set(" "$USER_SKILL"
assert_contains "event = \"BufWritePost\"" "$USER_SKILL"
assert_contains "event = \"VimEnter\"" "$USER_SKILL"
assert_contains "event = \"BufWinEnter\"" "$USER_SKILL"
assert_contains "## References" "$USER_SKILL"
assert_contains "\`plenary.path\`" "$USER_SKILL"

# plugin file generation and plugin-id section checks
(
  cd "$TMP_DIR"
  "$GEN" \
    --file "lua/plugins/example.lua" \
    --kind plugin \
    --force \
    >/dev/null
)

PLUGIN_SKILL="$TMP_DIR/.agents/skills/plugin.example/SKILL.md"
[[ -f "$PLUGIN_SKILL" ]] || { echo "missing output: $PLUGIN_SKILL" >&2; exit 1; }

assert_contains "folke/which-key.nvim" "$PLUGIN_SKILL"
assert_contains "nvim-lua/plenary.nvim" "$PLUGIN_SKILL"

echo "ok: generate_file_skill tests passed"
