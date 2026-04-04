local M = {}

local defaults = {
	nearby_lines = 5,
	before_cursor_chars = 900,
	after_cursor_chars = 220,
	max_payload_chars = 1800,
}

local state = {
	config = vim.deepcopy(defaults),
	initialized = false,
}

local function sanitize_prompt_text(text)
	if not text or text == "" then
		return ""
	end

	text = tostring(text)
	text = text:gsub("\r", "")
	text = text:gsub("[%z\1-\8\11-\31\127]", "")
	text = text:gsub("\n\n+", "\n\n")

	return text
end

local function clamp_head(text, max_chars)
	if #text <= max_chars then
		return text
	end
	return text:sub(1, max_chars)
end

local function clamp_tail(text, max_chars)
	if #text <= max_chars then
		return text
	end
	return text:sub(#text - max_chars + 1)
end

local function get_buf_path(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return vim.fn.fnamemodify(name, ":p")
end

function M.build_payload(_, _)
	local bufnr = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return ""
	end

	local path = get_buf_path(bufnr) or "[No Name]"
	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local total = vim.api.nvim_buf_line_count(bufnr)
	local from_line = math.max(1, row - state.config.nearby_lines)
	local to_line = math.min(total, row + state.config.nearby_lines)
	local lines = vim.api.nvim_buf_get_lines(bufnr, from_line - 1, to_line, false)

	local payload = table.concat({
		"[CURRENT_FILE] " .. path,
		"[CURSOR_LINE] " .. tostring(row),
		"[NEARBY_CODE]",
		sanitize_prompt_text(table.concat(lines, "\n")),
	}, "\n")

	return clamp_tail(sanitize_prompt_text(payload), state.config.max_payload_chars)
end

M.sanitize_prompt_text = sanitize_prompt_text
M.truncate_before = function(text)
	return clamp_tail(sanitize_prompt_text(text), state.config.before_cursor_chars)
end

M.truncate_after = function(text)
	return clamp_head(sanitize_prompt_text(text), state.config.after_cursor_chars)
end

function M.setup(opts)
	if state.initialized then
		return
	end
	state.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})
	state.initialized = true
end

return M
