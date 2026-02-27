#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/generate_skill.sh --plugin <lazy-plugin-name> --module <require-module> [options]

Required:
  --plugin <name>      Plugin name as used by lazy spec (example: nvim-telescope/telescope.nvim)
  --module <name>      Module name for require() (example: telescope)

Options:
  --skill-name <name>  Output folder name (default: derived from module)
  --depth <n>          Recursive depth for API table walk (default: 4)
  --max-items <n>      Max listed API entries (default: 200)
  --out-root <path>    Skills root directory (default: ./skills)
  --mirror-agents      Also write to ./.agents/skills/<skill-name>/SKILL.md
  --help               Show this help

Examples:
  scripts/generate_skill.sh --plugin nvim-telescope/telescope.nvim --module telescope
  scripts/generate_skill.sh --plugin ThePrimeagen/99 --module 99 --skill-name 99 --mirror-agents
EOF
}

PLUGIN=""
MODULE=""
SKILL_NAME=""
DEPTH="4"
MAX_ITEMS="200"
OUT_ROOT="./skills"
MIRROR_AGENTS="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --plugin)
      PLUGIN="${2:-}"
      shift 2
      ;;
    --module)
      MODULE="${2:-}"
      shift 2
      ;;
    --skill-name)
      SKILL_NAME="${2:-}"
      shift 2
      ;;
    --depth)
      DEPTH="${2:-}"
      shift 2
      ;;
    --max-items)
      MAX_ITEMS="${2:-}"
      shift 2
      ;;
    --out-root)
      OUT_ROOT="${2:-}"
      shift 2
      ;;
    --mirror-agents)
      MIRROR_AGENTS="1"
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

if [[ -z "$PLUGIN" || -z "$MODULE" ]]; then
  echo "Error: --plugin and --module are required." >&2
  usage >&2
  exit 1
fi

if [[ -z "$SKILL_NAME" ]]; then
  # Use first module token, normalized to lowercase with safe characters.
  SKILL_NAME="$(printf '%s' "$MODULE" | awk -F'.' '{print $1}' | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9._-]+/-/g')"
fi

if [[ ! "$DEPTH" =~ ^[0-9]+$ || ! "$MAX_ITEMS" =~ ^[0-9]+$ ]]; then
  echo "Error: --depth and --max-items must be positive integers." >&2
  exit 1
fi

ROOT_DIR="$(pwd)"
PLUGIN_REPO="$(printf '%s' "$PLUGIN" | awk -F'/' '{print $NF}')"
OUT_DIR="${OUT_ROOT%/}/${SKILL_NAME}"
OUT_FILE="${OUT_DIR}/SKILL.md"
AGENTS_OUT_FILE=".agents/skills/${SKILL_NAME}/SKILL.md"

mkdir -p "$OUT_DIR"
if [[ "$MIRROR_AGENTS" == "1" ]]; then
  mkdir -p ".agents/skills/${SKILL_NAME}"
fi

TMP_LUA="$(mktemp --suffix=.lua)"
TMP_INIT="$(mktemp --suffix=.lua)"
TMP_OK="$(mktemp)"
cleanup() {
  rm -f "$TMP_LUA"
  rm -f "$TMP_INIT"
  rm -f "$TMP_OK"
}
trap cleanup EXIT

cat > "$TMP_LUA" <<'LUA'
local plugin = assert(vim.env.SKILL_PLUGIN, "SKILL_PLUGIN is required")
local plugin_repo = assert(vim.env.SKILL_PLUGIN_REPO, "SKILL_PLUGIN_REPO is required")
local module_name = assert(vim.env.SKILL_MODULE, "SKILL_MODULE is required")
local skill_name = assert(vim.env.SKILL_NAME, "SKILL_NAME is required")
local out_file = assert(vim.env.SKILL_OUT_FILE, "SKILL_OUT_FILE is required")
local ok_file = assert(vim.env.SKILL_OK_FILE, "SKILL_OK_FILE is required")
local depth = tonumber(vim.env.SKILL_DEPTH or "4") or 4
local max_items = tonumber(vim.env.SKILL_MAX_ITEMS or "200") or 200
local root_dir = vim.env.SKILL_ROOT_DIR or vim.loop.cwd()

local function sorted_keys(tbl)
  local keys = {}
  for k in pairs(tbl) do
    table.insert(keys, k)
  end
  table.sort(keys, function(a, b)
    return tostring(a) < tostring(b)
  end)
  return keys
end

local function current_user_commands()
  local ok, cmds = pcall(vim.api.nvim_get_commands, { builtin = false })
  if not ok then
    return {}
  end
  local names = {}
  for name, _ in pairs(cmds) do
    names[name] = true
  end
  return names
end

local function command_diff(before, after)
  local diff = {}
  for name, _ in pairs(after) do
    if not before[name] then
      table.insert(diff, name)
    end
  end
  table.sort(diff)
  return diff
end

local function command_belongs_to_plugin(cmd_name, plugin_repo_name)
  local ok, out = pcall(vim.fn.execute, "verbose command " .. cmd_name)
  if not ok or type(out) ~= "string" then
    return false
  end
  local needle = "/lazy/" .. plugin_repo_name .. "/"
  return out:find(needle, 1, true) ~= nil
end

local function param_sig(fn)
  local ok, info = pcall(debug.getinfo, fn, "u")
  if not ok or not info then
    return "(...)"
  end

  if type(info.nparams) == "number" then
    local params = {}
    for i = 1, info.nparams do
      table.insert(params, ("p%d"):format(i))
    end
    if info.isvararg then
      table.insert(params, "...")
    end
    return "(" .. table.concat(params, ", ") .. ")"
  end

  return "(...)"
end

local api_items = {}
local seen = {}

local function push_item(kind, name, sig, nparams)
  if #api_items >= max_items then
    return
  end
  table.insert(api_items, {
    kind = kind,
    name = name,
    sig = sig,
    nparams = nparams or -1,
  })
end

local function walk(value, path, level)
  if #api_items >= max_items then
    return
  end
  if level > depth then
    return
  end

  local t = type(value)
  if t == "function" then
    local sig = param_sig(value)
    local ok, info = pcall(debug.getinfo, value, "u")
    local nparams = (ok and info and type(info.nparams) == "number") and info.nparams or -1
    push_item("function", path, sig, nparams)
    return
  end

  if t ~= "table" then
    push_item(t, path, "")
    return
  end

  if seen[value] then
    return
  end
  seen[value] = true

  push_item("table", path, "")

  for _, key in ipairs(sorted_keys(value)) do
    local child = value[key]
    local child_name = path .. "." .. tostring(key)
    walk(child, child_name, level + 1)
    if #api_items >= max_items then
      return
    end
  end
end

local before_cmds = current_user_commands()

local ok_lazy, lazy = pcall(require, "lazy")
if not ok_lazy then
  error("Failed to require lazy.nvim. Ensure this repo init.lua is used.")
end

local ok_load, load_err = pcall(lazy.load, { plugins = { plugin_repo } })
if not ok_load then
  error("Failed to lazy-load plugin '" .. plugin .. "': " .. tostring(load_err))
end

-- Give plugin commands/autocmds a chance to register.
pcall(vim.cmd, "doautocmd User VeryLazy")

local after_cmds = current_user_commands()
local new_commands = command_diff(before_cmds, after_cmds)
local filtered_commands = {}
for _, cmd in ipairs(new_commands) do
  if command_belongs_to_plugin(cmd, plugin_repo) then
    table.insert(filtered_commands, cmd)
  end
end
new_commands = filtered_commands

local ok_mod, mod = pcall(require, module_name)
if not ok_mod then
  error("Failed to require module '" .. module_name .. "': " .. tostring(mod))
end

walk(mod, ("require(%q)"):format(module_name), 0)
table.sort(api_items, function(a, b)
  return a.name < b.name
end)

local repo = plugin_repo
local local_readme = vim.fn.stdpath("data") .. "/lazy/" .. repo .. "/README.md"
local github_readme = "https://github.com/" .. plugin .. "/blob/master/README.md"

local function hard_comment(name)
  if name:match("setup") or name:match("config") or name:match("init") then
    return "setup entrypoint; call once and keep opts explicit."
  end
  if name:match("open") or name:match("toggle") or name:match("show") then
    return "UI/state entrypoint; verify window/buffer context before calling."
  end
  if name:match("run") or name:match("exec") or name:match("request") then
    return "side-effecting call; validate inputs and error paths."
  end
  return "argument contract may be non-obvious; check :help/README."
end

local hard_funcs = {}
for _, item in ipairs(api_items) do
  if item.kind == "function" then
    table.insert(hard_funcs, item)
  end
end
table.sort(hard_funcs, function(a, b)
  if a.nparams ~= b.nparams then
    return a.nparams > b.nparams
  end
  return a.name < b.name
end)

local lines = {}
table.insert(lines, "# " .. skill_name:gsub("^%l", string.upper) .. " API Reference")
table.insert(lines, "")
table.insert(lines, "This file is generated for plugin `" .. plugin .. "` and module `" .. module_name .. "`.")
table.insert(lines, "Use it as a fast API/command index before reading source.")
table.insert(lines, "")
table.insert(lines, "## Commands (`:`) added after force-load")
table.insert(lines, "")
if #new_commands == 0 then
  table.insert(lines, "_No new user commands detected from runtime diff._")
else
  table.insert(lines, "```vim")
  for _, name in ipairs(new_commands) do
    table.insert(lines, ":" .. name)
  end
  table.insert(lines, "```")
end

table.insert(lines, "")
table.insert(lines, "## Module API (`" .. module_name .. "`)")
table.insert(lines, "")
table.insert(lines, "```lua")
for _, item in ipairs(api_items) do
  if item.kind == "function" then
    table.insert(lines, item.name .. item.sig)
  elseif item.kind == "table" then
    table.insert(lines, item.name .. " -- table")
  else
    table.insert(lines, item.name .. " -- " .. item.kind)
  end
end
table.insert(lines, "```")

table.insert(lines, "")
table.insert(lines, "## Harder Calls (quick notes)")
table.insert(lines, "")
local hard_limit = math.min(8, #hard_funcs)
if hard_limit == 0 then
  table.insert(lines, "_No function exports detected._")
else
  for i = 1, hard_limit do
    local f = hard_funcs[i]
    table.insert(lines, "- `" .. f.name .. f.sig .. "`: " .. hard_comment(f.name))
  end
end

table.insert(lines, "")
table.insert(lines, "## References")
table.insert(lines, "")
table.insert(lines, "- Help: `:help " .. module_name .. "` and `:help " .. module_name .. ".*` topics")
table.insert(lines, "- Local README: `" .. local_readme .. "`")
table.insert(lines, "- GitHub README: " .. github_readme)
table.insert(lines, "")
table.insert(lines, "_Generated in headless mode with forced plugin load._")

local dir = vim.fn.fnamemodify(out_file, ":h")
vim.fn.mkdir(dir, "p")
vim.fn.writefile(lines, out_file)
vim.fn.writefile({ "ok" }, ok_file)
LUA

cat > "$TMP_INIT" <<'LUA'
local root = vim.env.SKILL_ROOT_DIR or vim.loop.cwd()
local plugin_repo = assert(vim.env.SKILL_PLUGIN_REPO, "SKILL_PLUGIN_REPO is required")
local plugin_dir = vim.fn.stdpath("data") .. "/lazy/" .. plugin_repo

vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")
require("lazy").setup({
  {
    name = plugin_repo,
    dir = plugin_dir,
    lazy = true,
  },
}, {
  rocks = { enabled = false },
  defaults = { lazy = true },
})
LUA

SKILL_PLUGIN="$PLUGIN" \
SKILL_PLUGIN_REPO="$PLUGIN_REPO" \
SKILL_MODULE="$MODULE" \
SKILL_NAME="$SKILL_NAME" \
SKILL_OUT_FILE="$OUT_FILE" \
SKILL_OK_FILE="$TMP_OK" \
SKILL_DEPTH="$DEPTH" \
SKILL_MAX_ITEMS="$MAX_ITEMS" \
SKILL_ROOT_DIR="$ROOT_DIR" \
XDG_STATE_HOME="/tmp/nvim-state" \
XDG_CACHE_HOME="/tmp/nvim-cache" \
nvim --headless --cmd "let g:headless = 1" -u "${TMP_INIT}" "+lua dofile('${TMP_LUA}')" +qa

if [[ ! -f "$TMP_OK" || ! -f "$OUT_FILE" ]]; then
  echo "Generation failed: output was not completed successfully." >&2
  exit 1
fi

if [[ "$MIRROR_AGENTS" == "1" ]]; then
  cp "$OUT_FILE" "$AGENTS_OUT_FILE"
fi

echo "Generated: $OUT_FILE"
if [[ "$MIRROR_AGENTS" == "1" ]]; then
  echo "Mirrored: $AGENTS_OUT_FILE"
fi
