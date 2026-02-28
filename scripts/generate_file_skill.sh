#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  scripts/generate_file_skill.sh --file <lua-file> [options]

Required:
  --file <path>            Target Lua file (typically under lua/user or lua/plugins)

Options:
  --kind <auto|user|plugin>
                           Skill prefix kind (default: auto)
  --skill-name <name>      Output folder name (default: user.<name> / plugin.<name>)
  --force                  Overwrite output file if it exists
  --help                   Show this help

Examples:
  scripts/generate_file_skill.sh --file lua/user/project_root.lua
  scripts/generate_file_skill.sh --file lua/plugins/dap.lua
EOF
}

FILE_PATH=""
KIND="auto"
SKILL_NAME=""
FORCE="0"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --file)
      FILE_PATH="${2:-}"
      shift 2
      ;;
    --kind)
      KIND="${2:-}"
      shift 2
      ;;
    --skill-name)
      SKILL_NAME="${2:-}"
      shift 2
      ;;
    --force)
      FORCE="1"
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

if [[ -z "$FILE_PATH" ]]; then
  echo "Error: --file is required." >&2
  usage >&2
  exit 1
fi

if [[ "$KIND" != "auto" && "$KIND" != "user" && "$KIND" != "plugin" ]]; then
  echo "Error: --kind must be one of: auto, user, plugin." >&2
  exit 1
fi

if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: file not found: $FILE_PATH" >&2
  exit 1
fi

FILE_PATH="$(realpath "$FILE_PATH")"
ROOT_DIR="$(pwd)"
REL_PATH="$FILE_PATH"
if [[ "$FILE_PATH" == "$ROOT_DIR/"* ]]; then
  REL_PATH="${FILE_PATH#"$ROOT_DIR/"}"
fi

if [[ "$KIND" == "auto" ]]; then
  case "$REL_PATH" in
    lua/user/*) KIND="user" ;;
    lua/plugins/*) KIND="plugin" ;;
    *)
      echo "Error: could not infer kind from path '$REL_PATH'. Use --kind user|plugin." >&2
      exit 1
      ;;
  esac
fi

BASE_NAME="$(basename "$REL_PATH" .lua)"
if [[ -z "$SKILL_NAME" ]]; then
  SKILL_NAME="${KIND}.${BASE_NAME}"
fi

OUT_DIR=".agents/skills/${SKILL_NAME}"
OUT_FILE="${OUT_DIR}/SKILL.md"

if [[ -f "$OUT_FILE" && "$FORCE" != "1" ]]; then
  echo "Error: output exists: $OUT_FILE (use --force to overwrite)." >&2
  exit 1
fi

mkdir -p "$OUT_DIR"

TMP_LUA="$(mktemp --suffix=.lua)"
TMP_OK="$(mktemp)"
cleanup() {
  rm -f "$TMP_LUA" "$TMP_OK"
}
trap cleanup EXIT

cat > "$TMP_LUA" <<'LUA'
local file_path = assert(vim.env.SKILL_FILE_PATH, "SKILL_FILE_PATH is required")
local rel_path = assert(vim.env.SKILL_REL_PATH, "SKILL_REL_PATH is required")
local kind = assert(vim.env.SKILL_KIND, "SKILL_KIND is required")
local skill_name = assert(vim.env.SKILL_NAME, "SKILL_NAME is required")
local out_file = assert(vim.env.SKILL_OUT_FILE, "SKILL_OUT_FILE is required")
local ok_file = assert(vim.env.SKILL_OK_FILE, "SKILL_OK_FILE is required")
local root_dir = vim.env.SKILL_ROOT_DIR or vim.loop.cwd()

local lines = vim.fn.readfile(file_path)

local function trim(s)
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

local function uniq_sorted(items)
  local seen = {}
  local out = {}
  for _, v in ipairs(items) do
    if v and v ~= "" and not seen[v] then
      seen[v] = true
      table.insert(out, v)
    end
  end
  table.sort(out)
  return out
end

local function module_path_from_rel(path)
  local m = path:match("^lua/(.+)%.lua$") or path:match("/lua/(.+)%.lua$")
  if not m then
    return nil
  end
  return (m:gsub("/", "."))
end

local module_path = module_path_from_rel(rel_path)
local return_var
local exports = {}
local requires = {}
local commands = {}
local keymaps = {}
local autocmds = {}
local plugin_ids = {}
local hard_funcs = {}
local in_autocmd_event_table = false

for _, line in ipairs(lines) do
  local ret = line:match("^%s*return%s+([%a_][%w_]*)%s*$")
  if ret then
    return_var = ret
  end

  for req in line:gmatch("require%s*%(%s*['\"]([^'\"]+)['\"]%s*%)") do
    table.insert(requires, req)
  end

  local cmd = line:match("nvim_create_user_command%s*%(%s*['\"]([^'\"]+)['\"]")
  if cmd then
    table.insert(commands, cmd)
  end

  if line:find("vim%.keymap%.set%s*%(") then
    table.insert(keymaps, trim(line))
  end

  local acmd_single = line:match("nvim_create_autocmd%s*%(%s*['\"]([^'\"]+)['\"]")
  if acmd_single then
    table.insert(autocmds, acmd_single)
    in_autocmd_event_table = false
  else
    local acmd_inline = line:match("nvim_create_autocmd%s*%(%s*{(.-)}")
    if acmd_inline then
      for ev in acmd_inline:gmatch("['\"]([^'\"]+)['\"]") do
        table.insert(autocmds, ev)
      end
      in_autocmd_event_table = false
    else
      if line:find("nvim_create_autocmd%s*%(%s*{") then
        in_autocmd_event_table = true
      end
      if in_autocmd_event_table then
        for ev in line:gmatch("['\"]([^'\"]+)['\"]") do
          table.insert(autocmds, ev)
        end
        if line:find("}%s*,") or line:find("}%)") then
          in_autocmd_event_table = false
        end
      end
    end
  end

  for plugin in line:gmatch("['\"]([%w_.-]+/[%w_.-]+)['\"]") do
    table.insert(plugin_ids, plugin)
  end
end

return_var = return_var or "M"

for _, line in ipairs(lines) do
  local name, params = line:match("^%s*function%s+" .. return_var .. "%.([%a_][%w_]*)%s*%(([^)]*)%)")
  if name then
    local sig = string.format("%s(%s)", name, trim(params))
    table.insert(exports, sig)
    local count = 0
    local cleaned = trim(params)
    if cleaned ~= "" then
      for part in cleaned:gmatch("([^,]+)") do
        local p = trim(part)
        if p ~= "" and p ~= "..." then
          count = count + 1
        end
      end
    end
    table.insert(hard_funcs, { sig = sig, nparams = count })
  end

  local name2, params2 = line:match("^%s*" .. return_var .. "%.([%a_][%w_]*)%s*=%s*function%s*%(([^)]*)%)")
  if name2 then
    local sig = string.format("%s(%s)", name2, trim(params2))
    table.insert(exports, sig)
    local count2 = 0
    local cleaned2 = trim(params2)
    if cleaned2 ~= "" then
      for part in cleaned2:gmatch("([^,]+)") do
        local p = trim(part)
        if p ~= "" and p ~= "..." then
          count2 = count2 + 1
        end
      end
    end
    table.insert(hard_funcs, { sig = sig, nparams = count2 })
  end
end

exports = uniq_sorted(exports)
requires = uniq_sorted(requires)
commands = uniq_sorted(commands)
autocmds = uniq_sorted(autocmds)
plugin_ids = uniq_sorted(plugin_ids)
keymaps = uniq_sorted(keymaps)

table.sort(hard_funcs, function(a, b)
  if a.nparams ~= b.nparams then
    return a.nparams > b.nparams
  end
  return a.sig < b.sig
end)

local function file_exists(path)
  return vim.uv.fs_stat(path) ~= nil
end

local function candidate_skill_names(ref)
  local out = {}
  local function add(v)
    if v and v ~= "" then
      table.insert(out, v)
    end
  end

  add(ref)
  if ref:find("/", 1, true) then
    local repo = ref:match("([^/]+)$")
    add(repo)
  end
  if ref:find("%.", 1, true) then
    local tail = ref:match("([^.]+)$")
    add(tail)
  end
  if not ref:match("%.nvim$") then
    add(ref .. ".nvim")
  end

  return uniq_sorted(out)
end

local function find_skill_path(ref)
  for _, c in ipairs(candidate_skill_names(ref)) do
    local p = root_dir .. "/.agents/skills/" .. c .. "/SKILL.md"
    if file_exists(p) then
      return ".agents/skills/" .. c .. "/SKILL.md"
    end
  end
  return nil
end

local references = {}
for _, plugin in ipairs(plugin_ids) do
  table.insert(references, plugin)
end
for _, req in ipairs(requires) do
  if not req:match("^user%.") and not req:match("^vim%.") then
    table.insert(references, req)
  end
end
references = uniq_sorted(references)

local out = {}
table.insert(out, "# " .. skill_name:gsub("^%l", string.upper) .. " API Reference")
table.insert(out, "")
table.insert(out, "This file is generated for source `" .. rel_path .. "`.")
table.insert(out, "Use it as a fast API/command index before reading source.")
table.insert(out, "")
table.insert(out, "## Commands (`:`) detected in file")
table.insert(out, "")
if #commands == 0 then
  table.insert(out, "_No user commands detected in static scan._")
else
  table.insert(out, "```vim")
  for _, c in ipairs(commands) do
    table.insert(out, ":" .. c)
    table.insert(out, "")
  end
  table.insert(out, "```")
end

table.insert(out, "")
table.insert(out, "## Module API (`" .. (module_path or rel_path) .. "`)")
table.insert(out, "")
if #exports == 0 and #keymaps == 0 and #autocmds == 0 then
  table.insert(out, "_No exported API/keymaps/autocmds detected in static scan._")
else
  table.insert(out, "```lua")
  if #exports > 0 then
    for _, sig in ipairs(exports) do
      if module_path then
        table.insert(out, ('require("%s").%s'):format(module_path, sig))
      else
        table.insert(out, sig)
      end
      table.insert(out, "")
    end
  end
  if #keymaps > 0 then
    for _, k in ipairs(keymaps) do
      table.insert(out, k)
      table.insert(out, "")
    end
  end
  if #autocmds > 0 then
    for _, a in ipairs(autocmds) do
      table.insert(out, 'event = "' .. a .. '"')
      table.insert(out, "")
    end
  end
  table.insert(out, "```")
end

table.insert(out, "")
table.insert(out, "## Harder Calls (quick notes)")
table.insert(out, "")
table.insert(out, "These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.")
table.insert(out, "Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.")
table.insert(out, "")
if #hard_funcs == 0 then
  table.insert(out, "_No exported function signatures detected._")
else
  local hard_limit = math.min(8, #hard_funcs)
  for i = 1, hard_limit do
    table.insert(out, "- `" .. hard_funcs[i].sig .. "`")
    table.insert(out, "")
  end
end

table.insert(out, "")
table.insert(out, "## References")
table.insert(out, "")
if #references == 0 then
  table.insert(out, "_No plugin/module references detected._")
else
  for _, ref in ipairs(references) do
    local skill_path = find_skill_path(ref)
    if skill_path then
      table.insert(out, "- `" .. ref .. "` (skill: `" .. skill_path .. "`)")
    else
      table.insert(out, "- `" .. ref .. "`")
    end
    table.insert(out, "")
  end
end
table.insert(out, "")
table.insert(out, "_Generated in headless mode from static file analysis._")

local dir = vim.fn.fnamemodify(out_file, ":h")
vim.fn.mkdir(dir, "p")
vim.fn.writefile(out, out_file)
vim.fn.writefile({ "ok" }, ok_file)
LUA

SKILL_FILE_PATH="$FILE_PATH" \
SKILL_REL_PATH="$REL_PATH" \
SKILL_KIND="$KIND" \
SKILL_NAME="$SKILL_NAME" \
SKILL_OUT_FILE="$OUT_FILE" \
SKILL_OK_FILE="$TMP_OK" \
SKILL_ROOT_DIR="$ROOT_DIR" \
XDG_STATE_HOME="/tmp/nvim-state" \
XDG_CACHE_HOME="/tmp/nvim-cache" \
nvim --headless -u NONE "+lua dofile('${TMP_LUA}')" +qa

if [[ ! -f "$TMP_OK" || ! -f "$OUT_FILE" ]]; then
  echo "Generation failed: output was not completed successfully." >&2
  exit 1
fi

echo "Generated: $OUT_FILE"
