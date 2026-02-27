local M = {}
local Path = require("plenary.path")
local project_root = require("user.project_root")

local defaults = {
	max_entries = 1000,
	dedupe_recent_window = 3,
	store_rel_path = ".nvim/history.jsonl",
	capture_debounce_ms = 150,
	capture = {
		BufEnter = true,
		InsertEnter = true,
		CursorHold = true,
		WrappedJump = true,
	},
	ignore_floating = true,
	ignore_buftypes = {
		[""] = false,
		nofile = true,
		prompt = true,
		terminal = true,
		quickfix = true,
		help = true,
	},
	ignore_filetypes = {
		OverseerList = true,
		OverseerForm = true,
		NvimTree = true,
		undotree = true,
		diff = true,
	},
}

local state = {
	config = vim.deepcopy(defaults),
	project = {},
	is_navigating = false,
	notify_once = {},
}

local function now_ms()
	return vim.uv.now()
end

local function notify(msg, level)
	vim.notify(msg, level or vim.log.levels.INFO)
end

local function normalize_path(path)
	if not path or path == "" then
		return ""
	end
	return vim.fn.fnamemodify(path, ":p")
end

local function starts_with_drive(path)
	return path:match("^[A-Za-z]:") ~= nil
end

local function is_absolute_path(path)
	return path:sub(1, 1) == "/" or starts_with_drive(path)
end

local function canonical_path(path)
	if not path or path == "" then
		return ""
	end
	local normalized = normalize_path(path)
	local real = vim.uv.fs_realpath(normalized)
	return real or normalized
end

local function is_same_file_as_current(target_path)
	local current_buf = vim.api.nvim_get_current_buf()
	local current_path = vim.api.nvim_buf_get_name(current_buf)
	if current_path == "" then
		return false
	end

	local current_canonical = canonical_path(current_path)
	local target_canonical = canonical_path(target_path)
	if current_canonical ~= "" and target_canonical ~= "" and current_canonical == target_canonical then
		return true
	end

	local target_buf = vim.fn.bufnr(target_path)
	return target_buf > 0 and target_buf == current_buf
end

local function buf_line_text(bufnr, line)
	if line < 1 then
		return ""
	end
	local ok, lines = pcall(vim.api.nvim_buf_get_lines, bufnr, line - 1, line, false)
	if not ok or not lines or not lines[1] then
		return ""
	end
	return vim.trim(lines[1])
end

local function safe_json_decode(line)
	return pcall(vim.json.decode, line)
end

local function safe_json_encode(tbl)
	return pcall(vim.json.encode, tbl)
end

local function atomic_write_lines(path, lines)
	local tmp = path .. ".tmp"
	local ok, err = pcall(vim.fn.writefile, lines, tmp)
	if not ok then
		return false, err
	end
	local renamed = os.rename(tmp, path)
	if not renamed then
		pcall(vim.fn.delete, tmp)
		return false, "rename failed"
	end
	return true
end

local function merge_config(user)
	if not user then
		return vim.deepcopy(defaults)
	end
	return vim.tbl_deep_extend("force", vim.deepcopy(defaults), user)
end

local function get_project_state(root)
	if not state.project[root] then
		state.project[root] = {
			entries = nil,
			nav_index = nil,
			last_pos_id = "",
			last_capture_ms = 0,
			dirty = false,
		}
	end
	return state.project[root]
end

M.get_project_root = function()
	return normalize_path(project_root.resolve())
end

local function get_store_path(root)
	return Path:new(root, state.config.store_rel_path):expand()
end

local function get_legacy_store_path(root)
	return Path:new(root, ".nvim/history"):expand()
end

local function ensure_store_dir(root)
	local store_path = get_store_path(root)
	local dir = vim.fn.fnamemodify(store_path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		Path:new(dir):mkdir({ parents = true })
	end
	return store_path
end

local function as_rel_path(root, file_path)
	local ok, rel = pcall(function()
		return Path:new(file_path):make_relative(root)
	end)
	if ok and rel and rel ~= "" and rel ~= "." then
		return rel
	end
	return file_path
end

local function make_pos_id(entry)
	return string.format("%s:%d:%d", entry.path, entry.line, entry.col)
end

local function trim_entries(entries)
	while #entries > state.config.max_entries do
		table.remove(entries, 1)
	end
end

local function parse_legacy_line(line)
	local parts = vim.split(line, "|", { plain = true })
	if #parts < 5 then
		return nil
	end
	local ts = tonumber(parts[1])
	local ln = tonumber(parts[4])
	local col = tonumber(parts[5])
	if not ts or not ln or not col or parts[3] == "" then
		return nil
	end
	return {
		ts = ts,
		action = parts[2] ~= "" and parts[2] or "Unknown",
		root = nil,
		path = parts[3],
		line = ln,
		col = col,
		line_text = "",
		tracked = false,
	}
end

local function decode_line(raw)
	local ok, decoded = safe_json_decode(raw)
	if ok and type(decoded) == "table" and decoded.path and decoded.line and decoded.col then
		decoded.ts = tonumber(decoded.ts) or os.time()
		decoded.action = tostring(decoded.action or "Unknown")
		decoded.line = tonumber(decoded.line) or 1
		decoded.col = tonumber(decoded.col) or 0
		decoded.line_text = tostring(decoded.line_text or "")
		decoded.tracked = decoded.tracked == true
		decoded.root = decoded.root and tostring(decoded.root) or nil
		return decoded
	end
	return parse_legacy_line(raw)
end

local function encode_entry(entry)
	local ok, encoded = safe_json_encode(entry)
	if ok then
		return encoded
	end
	return nil
end

local function load_entries(root)
	local ps = get_project_state(root)
	if ps.entries then
		return ps.entries
	end

	local path = get_store_path(root)
	local source_path = path
	local from_legacy_path = false
	if vim.fn.filereadable(source_path) ~= 1 then
		local legacy_path = get_legacy_store_path(root)
		if vim.fn.filereadable(legacy_path) == 1 then
			source_path = legacy_path
			from_legacy_path = true
		else
			ps.entries = {}
			return ps.entries
		end
	end

	local lines = vim.fn.readfile(source_path)
	local entries = {}
	local legacy_seen = false
	for _, line in ipairs(lines) do
		if line ~= "" then
			local entry = decode_line(line)
			if entry then
				if not entry.root then
					entry.root = root
				end
				table.insert(entries, entry)
				if line:find("|", 1, true) then
					legacy_seen = true
				end
			end
		end
	end

	trim_entries(entries)
	ps.entries = entries

	if legacy_seen or from_legacy_path then
		local encoded = {}
		for _, entry in ipairs(entries) do
			local line = encode_entry(entry)
			if line then
				table.insert(encoded, line)
			end
		end
		if #encoded > 0 then
			local ok = atomic_write_lines(path, encoded)
			if not ok then
				notify("History: failed to migrate legacy history file", vim.log.levels.WARN)
			end
		end
	end

	return ps.entries
end

local function flush_entries(root)
	local ps = get_project_state(root)
	if not ps.entries then
		return true
	end

	local store_path = ensure_store_dir(root)
	local lines = {}
	for _, entry in ipairs(ps.entries) do
		local encoded = encode_entry(entry)
		if encoded then
			table.insert(lines, encoded)
		end
	end

	local ok, err = atomic_write_lines(store_path, lines)
	if not ok then
		notify("History: failed to write store (" .. tostring(err) .. ")", vim.log.levels.ERROR)
		return false
	end
	ps.dirty = false
	return true
end

local function is_git_repo(root)
	local git_dir = Path:new(root, ".git")
	return git_dir:exists()
end

local function git_track_state(root, abs_path)
	if not is_git_repo(root) then
		return false
	end
	local rel = as_rel_path(root, abs_path)
	local out = vim.fn.system({ "git", "-C", root, "ls-files", "--error-unmatch", rel })
	return vim.v.shell_error == 0 and out ~= ""
end

local function git_resolve_rename(root, old_rel_path)
	if not is_git_repo(root) then
		return nil
	end

	local cmd = {
		"git",
		"-C",
		root,
		"log",
		"--follow",
		"--name-status",
		"--pretty=format:",
		"--",
		old_rel_path,
	}
	local out = vim.fn.systemlist(cmd)
	if vim.v.shell_error ~= 0 then
		return nil
	end

	for _, line in ipairs(out) do
		if line:sub(1, 1) == "R" then
			local parts = vim.split(line, "\t", { plain = true })
			if #parts >= 3 then
				local old_name = parts[2]
				local new_name = parts[3]
				if old_name == old_rel_path and new_name ~= "" then
					local candidate = Path:new(root, new_name):expand()
					if vim.fn.filereadable(candidate) == 1 then
						return candidate
					end
				end
			end
		end
	end

	return nil
end

local function resolve_path(root, entry)
	local candidate = entry.path
	if not is_absolute_path(candidate) then
		candidate = Path:new(root, candidate):expand()
	end
	candidate = normalize_path(candidate)

	if vim.fn.filereadable(candidate) == 1 then
		return candidate
	end

	local rel = as_rel_path(root, candidate)
	local renamed = git_resolve_rename(root, rel)
	if renamed then
		return normalize_path(renamed)
	end

	return nil
end

local function clamp_cursor(bufnr, line, col)
	local line_count = vim.api.nvim_buf_line_count(bufnr)
	if line_count < 1 then
		return { 1, 0 }
	end
	local clamped_line = math.max(1, math.min(line, line_count))
	local max_col = math.max(0, #vim.api.nvim_buf_get_lines(bufnr, clamped_line - 1, clamped_line, false)[1] - 1)
	local clamped_col = math.max(0, math.min(col, max_col))
	return { clamped_line, clamped_col }
end

local function find_line_by_text(bufnr, target_text)
	if target_text == "" then
		return nil
	end
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
	for i, line in ipairs(lines) do
		if vim.trim(line) == target_text then
			return i
		end
	end
	return nil
end

local function restore_cursor(entry)
	local bufnr = vim.api.nvim_get_current_buf()
	local line = entry.line
	local col = entry.col
	local current_text = buf_line_text(bufnr, line)
	if current_text == "" or (entry.line_text ~= "" and current_text ~= entry.line_text) then
		local found_line = find_line_by_text(bufnr, entry.line_text)
		if found_line then
			line = found_line
		else
			line = line >= 1 and line or 1
		end
	end
	local cursor = clamp_cursor(bufnr, line, col)
	vim.api.nvim_win_set_cursor(0, cursor)
end

local function open_entry(root, entry)
	local target = resolve_path(root, entry)
	if not target then
		return false
	end

	state.is_navigating = true
	local ok, err = pcall(function()
		if not is_same_file_as_current(target) then
			local escaped = vim.fn.fnameescape(target)
			vim.cmd("edit " .. escaped)
		end
		restore_cursor(entry)
	end)
	state.is_navigating = false
	if not ok then
		notify("History: failed opening entry (" .. tostring(err) .. ")", vim.log.levels.ERROR)
		return false
	end
	return true
end

local function is_valid_capture_context()
	if state.is_navigating then
		return false
	end

	local winid = vim.api.nvim_get_current_win()
	if not vim.api.nvim_win_is_valid(winid) then
		return false
	end

	if state.config.ignore_floating then
		local win_config = vim.api.nvim_win_get_config(winid)
		if win_config and win_config.relative ~= "" then
			return false
		end
	end

	local bufnr = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return false
	end

	local buftype = vim.bo[bufnr].buftype
	if state.config.ignore_buftypes[buftype] then
		return false
	end

	local filetype = vim.bo[bufnr].filetype
	if filetype == "" then
		return false
	end
	if state.config.ignore_filetypes[filetype] or filetype:match("^dapui_") then
		return false
	end

	local file_path = normalize_path(vim.api.nvim_buf_get_name(bufnr))
	if file_path == "" or not is_absolute_path(file_path) then
		return false
	end

	if vim.fn.filereadable(file_path) ~= 1 then
		return false
	end

	return true
end

local function maybe_record(action_name)
	if not is_valid_capture_context() then
		return false
	end

	local root = M.get_project_root()
	local ps = get_project_state(root)
	local t = now_ms()
	if t - ps.last_capture_ms < state.config.capture_debounce_ms then
		return false
	end

	local winid = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()
	local cursor = vim.api.nvim_win_get_cursor(winid)
	local abs_path = normalize_path(vim.api.nvim_buf_get_name(bufnr))
	local rel_path = as_rel_path(root, abs_path)

	local entry = {
		ts = os.time(),
		action = action_name or "Switch",
		root = root,
		path = rel_path,
		line = cursor[1],
		col = cursor[2],
		line_text = buf_line_text(bufnr, cursor[1]),
		tracked = git_track_state(root, abs_path),
	}

	local pos_id = make_pos_id(entry)
	if pos_id == ps.last_pos_id then
		return false
	end

	local entries = load_entries(root)

	if ps.nav_index and ps.nav_index < #entries then
		for i = #entries, ps.nav_index + 1, -1 do
			table.remove(entries, i)
		end
	end

	local found_idx = nil
	local from = math.max(1, #entries - state.config.dedupe_recent_window + 1)
	for i = #entries, from, -1 do
		local e = entries[i]
		if e.path == entry.path and e.line == entry.line and e.col == entry.col then
			found_idx = i
			break
		end
	end
	if found_idx then
		table.remove(entries, found_idx)
	end

	table.insert(entries, entry)
	trim_entries(entries)

	ps.nav_index = #entries
	ps.last_pos_id = pos_id
	ps.last_capture_ms = t
	ps.dirty = true
	flush_entries(root)
	return true
end

M.record = function(action_name)
	return maybe_record(action_name)
end

local function nav_from_index(root, start_idx, direction)
	local ps = get_project_state(root)
	local entries = load_entries(root)
	if #entries == 0 then
		return false
	end

	local idx = start_idx
	while idx >= 1 and idx <= #entries do
		local entry = entries[idx]
		if open_entry(root, entry) then
			ps.nav_index = idx
			ps.last_pos_id = make_pos_id(entry)
			return true
		end

		local key = root .. ":" .. entry.path
		if not state.notify_once[key] then
			state.notify_once[key] = true
			notify("History: skipped missing entry " .. entry.path, vim.log.levels.WARN)
		end

		idx = idx + direction
	end

	return false
end

M.nav_history = function(direction)
	local root = M.get_project_root()
	local ps = get_project_state(root)
	local entries = load_entries(root)
	if #entries == 0 then
		return
	end

	if not ps.nav_index then
		ps.nav_index = #entries
	end

	local new_idx = ps.nav_index + direction
	if new_idx < 1 then
		new_idx = 1
		notify("Start of history", vim.log.levels.INFO)
	elseif new_idx > #entries then
		new_idx = #entries
		notify("End of history", vim.log.levels.INFO)
	end

	if new_idx == ps.nav_index and direction ~= 0 then
		return
	end

	local ok, err = pcall(nav_from_index, root, new_idx, direction < 0 and -1 or 1)
	if not ok then
		state.is_navigating = false
		notify("History navigation failed: " .. tostring(err), vim.log.levels.ERROR)
	end
end

M.back = function()
	M.nav_history(-1)
end

M.forward = function()
	M.nav_history(1)
end

M.wrap_jump = function(cmd, action)
	return function()
		if state.config.capture.WrappedJump then
			M.record(action or "Jump")
		end
		if type(cmd) == "string" then
			vim.cmd(cmd)
		else
			cmd()
		end
	end
end

M.list_history = function()
	local root = M.get_project_root()
	local entries = load_entries(root)
	if #entries == 0 then
		return
	end

	local reversed = {}
	for i = #entries, 1, -1 do
		table.insert(reversed, entries[i])
	end

	local pickers = require("telescope.pickers")
	local finders = require("telescope.finders")
	local conf = require("telescope.config").values
	local actions = require("telescope.actions")
	local action_state = require("telescope.actions.state")

	pickers
		.new({}, {
			prompt_title = "History: " .. vim.fn.fnamemodify(root, ":t"),
			finder = finders.new_table({
				results = reversed,
				entry_maker = function(entry)
					return {
						value = entry,
						display = string.format(
							"[%s] %-10s │ %s:%s",
							os.date("%H:%M", tonumber(entry.ts)),
							entry.action,
							entry.path,
							entry.line
						),
						ordinal = string.format("%s|%s|%s", entry.action, entry.path, entry.line),
						filename = is_absolute_path(entry.path) and entry.path or (root .. "/" .. entry.path),
						lnum = tonumber(entry.line),
						col = tonumber(entry.col),
					}
				end,
			}),
			previewer = conf.file_previewer({}),
			sorter = conf.generic_sorter({}),
			attach_mappings = function(prompt_bufnr, _)
				actions.select_default:replace(function()
					local selection = action_state.get_selected_entry()
					actions.close(prompt_bufnr)
					if not selection or not selection.value then
						return
					end
					local ok = open_entry(root, selection.value)
					if not ok then
						notify("History: unable to open selected entry", vim.log.levels.WARN)
					end
				end)
				return true
			end,
		})
		:find()
end

M.setup = function(opts)
	state.config = merge_config(opts)

	local group = vim.api.nvim_create_augroup("ProjectHistory", { clear = true })

	if state.config.capture.InsertEnter then
		vim.api.nvim_create_autocmd("InsertEnter", {
			group = group,
			callback = function()
				M.record("Insert")
			end,
		})
	end

	if state.config.capture.BufEnter then
		vim.api.nvim_create_autocmd("BufEnter", {
			group = group,
			callback = function()
				M.record("Switch")
			end,
		})
	end

	if state.config.capture.CursorHold then
		vim.api.nvim_create_autocmd("CursorHold", {
			group = group,
			callback = function()
				M.record("CursorHold")
			end,
		})
	end
end

M.setup()

return M
