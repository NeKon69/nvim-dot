local M = {}

local defaults = {
	nearby_lines = 60,
	recent_buffers_max = 3,
	recent_buffer_window = 20,
	recent_buffer_chars = 280,
	diagnostics_window = 5,
	diagnostics_max = 6,
	max_payload_chars = 4200,
}

local state = {
	config = vim.deepcopy(defaults),
	initialized = false,
	positions = {},
	recency = {},
}

local function sanitize_prompt_text(text)
	if not text or text == "" then
		return ""
	end
	text = tostring(text)
	text = text:gsub("\r", "")
	text = text:gsub("[^\n\t\32-\126]", " ")
	text = text:gsub("[ \t]+", " ")
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

local function touch_recency(path)
	if not path then
		return
	end
	for i = #state.recency, 1, -1 do
		if state.recency[i] == path then
			table.remove(state.recency, i)
			break
		end
	end
	table.insert(state.recency, 1, path)
	while #state.recency > 100 do
		table.remove(state.recency)
	end
end

local function capture_position(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local path = get_buf_path(bufnr)
	if not path then
		return
	end
	local cursor = vim.api.nvim_win_get_cursor(0)
	state.positions[path] = {
		row = cursor[1],
		col = cursor[2],
		ts = os.time(),
	}
	touch_recency(path)
end

local function collect_local_diagnostics(bufnr, row)
	local all = vim.diagnostic.get(bufnr)
	if #all == 0 then
		return ""
	end
	local out = {}
	for _, d in ipairs(all) do
		local lnum = (d.lnum or 0) + 1
		if math.abs(lnum - row) <= state.config.diagnostics_window then
			local msg = tostring(d.message or ""):gsub("\n", " ")
			table.insert(out, string.format("L%d:%d %s", lnum, (d.col or 0) + 1, msg))
		end
		if #out >= state.config.diagnostics_max then
			break
		end
	end
	return table.concat(out, "\n")
end

local function collect_recent_buffers_context(current_path)
	local out = {}
	local added = 0
	for _, path in ipairs(state.recency) do
		if path ~= current_path and added < state.config.recent_buffers_max then
			local found_bufnr = nil
			for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
				if
					vim.api.nvim_buf_is_valid(bufnr)
					and vim.api.nvim_buf_is_loaded(bufnr)
					and vim.bo[bufnr].buftype == ""
				then
					if get_buf_path(bufnr) == path then
						found_bufnr = bufnr
						break
					end
				end
			end
			if found_bufnr and state.positions[path] then
				local pos = state.positions[path]
				local total = vim.api.nvim_buf_line_count(found_bufnr)
				local from_line = math.max(1, (pos.row or 1) - state.config.recent_buffer_window)
				local to_line = math.min(total, (pos.row or 1) + state.config.recent_buffer_window)
				local lines = vim.api.nvim_buf_get_lines(found_bufnr, from_line - 1, to_line, false)
				local snippet =
					sanitize_prompt_text(clamp_head(table.concat(lines, "\n"), state.config.recent_buffer_chars))
				table.insert(out, string.format("[BUF %d] %s @L%d\n%s", added + 1, path, pos.row or 1, snippet))
				added = added + 1
			end
		end
		if added >= state.config.recent_buffers_max then
			break
		end
	end
	return table.concat(out, "\n\n")
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
	local diagnostics = collect_local_diagnostics(bufnr, row)
	local recent_buffers = collect_recent_buffers_context(path)

	local payload = table.concat({
		"/*__LOCAL_CONTEXT_BEGIN__",
		"[CURRENT_FILE] " .. path,
		"[CURSOR_LINE] " .. tostring(row),
		"[DIAGNOSTICS_NEAR_CURSOR]\n" .. diagnostics,
		"[NEARBY_CODE]",
		sanitize_prompt_text(table.concat(lines, "\n")),
		"[RECENT_OPEN_BUFFERS_CONTEXT]\n" .. recent_buffers,
		"__LOCAL_CONTEXT_END__*/",
	}, "\n")

	return clamp_tail(sanitize_prompt_text(payload), state.config.max_payload_chars)
end

M.sanitize_prompt_text = sanitize_prompt_text

function M.setup(opts)
	if state.initialized then
		return
	end
	state.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

	local group = vim.api.nvim_create_augroup("MinuetContext", { clear = true })
	vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "BufLeave" }, {
		group = group,
		callback = function(args)
			vim.schedule(function()
				capture_position(args.buf)
			end)
		end,
	})

	capture_position(vim.api.nvim_get_current_buf())
	state.initialized = true
end

return M
