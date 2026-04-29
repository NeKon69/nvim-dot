local M = {}

local state = {
	request_id = nil,
	patch_file = nil,
	files = {},
	index = 1,
	accepted_files = {},
	approved_history = {},
	approval_note_sent = false,
	batch_active = false,
	tab = nil,
	buf = nil,
	hunk_lines = {},
	line_kinds = {},
	loading_request = false,
	queue = {},
	event_job = nil,
	reconnect_timer = nil,
}

local ns = vim.api.nvim_create_namespace("opencode-review")

local defaults = {
	debug = true,
	idle_delay_ms = 300,
	port = 27100,
	reconnect_delay_ms = 2000,
	keymaps = {
		accept = "da",
		accept_all = "dA",
		reject = "dr",
		comment = "dc",
		close = "dq",
	},
}

local opts = vim.deepcopy(defaults)

local function log(message)
	if not opts.debug then
		return
	end

	local path = vim.fn.stdpath("log") .. "/opencode-review.log"
	local line = string.format("[%s] %s", os.date("%Y-%m-%d %H:%M:%S"), message)
	pcall(vim.fn.writefile, { line }, path, "a")
end

local function notify(message, level)
	vim.notify(message, level or vim.log.levels.INFO, { title = "opencode-review" })
end

local function add_unique(list, item)
	if item and not vim.tbl_contains(list, item) then
		list[#list + 1] = item
	end
end

local function approved_files_for_note()
	local files = vim.deepcopy(state.approved_history)
	for _, file in ipairs(state.accepted_files) do
		add_unique(files, file)
	end
	return files
end

local function close_tab()
	if state.tab and vim.api.nvim_tabpage_is_valid(state.tab) then
		vim.api.nvim_set_current_tabpage(state.tab)
		pcall(vim.cmd, "tabclose")
	end
	state.tab = nil
end

local function reset_active()
	log("reset_active")
	close_tab()
	if state.patch_file then
		vim.fn.delete(state.patch_file)
	end
	state.request_id = nil
	state.patch_file = nil
	state.files = {}
	state.index = 1
	state.accepted_files = {}
	state.approval_note_sent = false
	state.hunk_lines = {}
	state.line_kinds = {}
	state.buf = nil
end

local function reset()
	reset_active()
	state.queue = {}
	state.loading_request = false
	state.approved_history = {}
	state.approval_note_sent = false
	state.batch_active = false
end

local function clear_review_batch()
	if state.request_id or state.loading_request or #state.queue > 0 then
		return
	end
	if state.batch_active then
		log("clear_review_batch")
	end
	state.approved_history = {}
	state.approval_note_sent = false
	state.batch_active = false
end

local function endpoint(path)
	return string.format("http://127.0.0.1:%d%s", opts.port, path)
end

local function reply_permission(request_id, reply)
	local body = vim.json.encode({ reply = reply })
	log(string.format("reply_permission: id=%s reply=%s", request_id, reply))
	vim.system({
		"curl",
		"-sS",
		"-X",
		"POST",
		endpoint("/permission/" .. request_id .. "/reply"),
		"-H",
		"content-type: application/json",
		"-d",
		body,
	}, { text = true }, function(result)
		if result.code ~= 0 then
			log("reply_permission failed: " .. (result.stderr or ""))
		end
	end)
end

local function extract_files(event)
	local files = {}
	local seen = {}
	local diff = event.properties.metadata and event.properties.metadata.diff or ""

	for line in diff:gmatch("[^\n]+") do
		local path = line:match("^Index:%s+(.+)$") or line:match("^%+%+%+%s+b/(.+)$")
		if path and path ~= "/dev/null" and not seen[path] then
			seen[path] = true
			files[#files + 1] = path
		end
	end

	local filepath = event.properties.metadata and event.properties.metadata.filepath
	if #files == 0 and filepath and filepath ~= "" then
		files[1] = filepath
	end

	return files
end

local function selected_text()
	local mode = vim.fn.mode()
	if mode ~= "v" and mode ~= "V" and mode ~= "\22" then
		local line = vim.api.nvim_get_current_line()
		return { line }, vim.api.nvim_win_get_cursor(0)[1], vim.api.nvim_win_get_cursor(0)[1]
	end

	local start_pos = vim.fn.getpos("v")
	local end_pos = vim.fn.getpos(".")
	local start_line = math.min(start_pos[2], end_pos[2])
	local end_line = math.max(start_pos[2], end_pos[2])
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	return lines, start_line, end_line
end

local function format_review_lines(lines, start_line)
	local formatted = {}
	for i, line in ipairs(lines) do
		local kind = state.line_kinds[start_line + i - 1]
		local prefix = " "
		if kind == "add" then
			prefix = "+"
		elseif kind == "delete" then
			prefix = "-"
		end
		formatted[#formatted + 1] = prefix .. line
	end
	return table.concat(formatted, "\n")
end

local function find_opencode_terminal()
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
			local name = vim.api.nvim_buf_get_name(buf)
			if name:find("opencode", 1, true) then
				local job = vim.b[buf].terminal_job_id
				if job then
					for _, win in ipairs(vim.api.nvim_list_wins()) do
						if vim.api.nvim_win_get_buf(win) == buf then
							return job, buf, win
						end
					end
					return job, buf, nil
				end
			end
		end
	end
end

local function open_opencode_window()
	local job, _, win = find_opencode_terminal()
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_set_current_win(win)
		return job
	end

	if job then
		require("opencode").toggle()
		return job
	end

	require("opencode").start()
end

local function append_prompt_http(prompt)
	vim.system({
		"curl",
		"-sS",
		"-X",
		"POST",
		endpoint("/tui/append-prompt") .. "?directory=" .. vim.uri_encode(vim.fn.getcwd(), "rfc3986"),
		"-H",
		"content-type: application/json",
		"-d",
		vim.json.encode({ text = prompt }),
	}, { text = true }, function(result)
		if result.code ~= 0 then
			log("append prompt failed: " .. (result.stderr or ""))
			vim.schedule(function()
				notify("Failed to insert review note into OpenCode", vim.log.levels.ERROR)
			end)
		end
	end)
end

local function paste_prompt(prompt)
	open_opencode_window()
	vim.defer_fn(function()
		local job = find_opencode_terminal()
		if not job then
			log("paste_prompt: no OpenCode terminal job, falling back to HTTP append")
			append_prompt_http(prompt)
			return
		end

		vim.fn.chansend(job, "\n\27[200~" .. prompt .. "\27[201~")
	end, 100)
end

local function send_review_comment()
	local file = state.files[state.index] or vim.api.nvim_buf_get_name(0)
	local lines, start_line, end_line = selected_text()
	local range = start_line == end_line and tostring(start_line) or (start_line .. "-" .. end_line)
	local prompt_lines = {}
	local approved_files = approved_files_for_note()
	if not state.approval_note_sent and #approved_files > 0 then
		prompt_lines[#prompt_lines + 1] = "I accepted edits to these files:"
		for _, accepted_file in ipairs(approved_files) do
			prompt_lines[#prompt_lines + 1] = "- " .. accepted_file
		end
		prompt_lines[#prompt_lines + 1] = "I approve changes in these files but not the whole change."
		prompt_lines[#prompt_lines + 1] = ""
		state.approved_history = {}
		state.accepted_files = {}
		state.approval_note_sent = true
	end
	vim.list_extend(prompt_lines, {
		"Review note for " .. file .. ":" .. range .. ":",
		"```",
		format_review_lines(lines, start_line),
		"```",
		"",
	})
	local prompt = table.concat(prompt_lines, "\n")
	local request_id = state.request_id
	if request_id then
		log("send_review_comment: rejecting request and keeping preview " .. request_id)
		state.request_id = nil
		reply_permission(request_id, "reject")
	end

	paste_prompt(prompt)
	notify("Review note inserted into OpenCode prompt")
end

local function normalize_file(path)
	if not path or path == "" then
		return path
	end
	if vim.fn.fnamemodify(path, ":p") == path then
		return vim.fn.fnamemodify(path, ":p")
	end
	return vim.fn.fnamemodify(vim.fn.getcwd() .. "/" .. path, ":p")
end

local function parse_hunk_header(line)
	local old_start, old_count = line:match("^@@ %-(%d+),?(%d*) %+%d+,?%d* @@")
	if not old_start then
		return nil
	end
	return tonumber(old_start), tonumber(old_count ~= "" and old_count or "1")
end

local open_file_preview

local function render_diff(lines, file)
	local rendered = {}
	local highlights = {}
	local line_kinds = {}
	local hunk_lines = {}
	local active = false
	local target = normalize_file(file)
	local original = {}
	local original_path = normalize_file(file)
	if original_path and vim.fn.filereadable(original_path) == 1 then
		original = vim.fn.readfile(original_path)
	end
	local original_line = 1

	local function add_line(text, hl_group)
		rendered[#rendered + 1] = text
		if hl_group then
			highlights[#rendered] = hl_group
		end
		if hl_group == "DiffAdd" then
			line_kinds[#rendered] = "add"
		elseif hl_group == "DiffDelete" then
			line_kinds[#rendered] = "delete"
		else
			line_kinds[#rendered] = "context"
		end
	end

	local function copy_until(line_nr)
		while original_line < line_nr and original[original_line] do
			add_line(original[original_line])
			original_line = original_line + 1
		end
	end

	local i = 1
	while i <= #lines do
		local line = lines[i]
		local diff_file = line:match("^diff %-%-git a/.+ b/(.+)$") or line:match("^Index:%s+(.+)$")
		if diff_file then
			active = normalize_file(diff_file) == target
		elseif active then
			if line:match("^diff %-%-git ") or line:match("^Index:%s+") then
				active = false
			elseif line:match("^@@") then
				local old_start, old_count = parse_hunk_header(line)
				if old_start then
					local hunk_start = old_start == 0 and 1 or old_start
					copy_until(hunk_start)
					local hunk_marked = false
					i = i + 1
					while
						i <= #lines
						and not lines[i]:match("^@@")
						and not lines[i]:match("^diff %-%-git ")
						and not lines[i]:match("^Index:%s+")
					do
						local hunk_line = lines[i]
						local prefix = hunk_line:sub(1, 1)
						if prefix == " " then
							add_line(hunk_line:sub(2))
							original_line = original_line + 1
						elseif prefix == "-" then
							add_line(hunk_line:sub(2), "DiffDelete")
							if not hunk_marked then
								hunk_lines[#hunk_lines + 1] = #rendered
								hunk_marked = true
							end
							original_line = original_line + 1
						elseif prefix == "+" then
							add_line(hunk_line:sub(2), "DiffAdd")
							if not hunk_marked then
								hunk_lines[#hunk_lines + 1] = #rendered
								hunk_marked = true
							end
						end
						i = i + 1
					end
					i = i - 1
				elseif old_count == 0 then
					copy_until(old_start + 1)
				end
			end
		end
		i = i + 1
	end

	copy_until(#original + 1)

	if #rendered == 0 then
		return lines, {}, {}, {}
	end

	return rendered, highlights, hunk_lines, line_kinds
end

local function begin_request(request)
	log("begin_request: " .. request.id)
	reset_active()
	state.request_id = request.id
	state.files = request.files
	state.index = 1
	state.patch_file = vim.fn.tempname() .. ".patch"

	if vim.fn.writefile(vim.split(request.diff, "\n"), state.patch_file) ~= 0 then
		log("begin_request: write patch failed")
		notify("Failed to write OpenCode patch preview", vim.log.levels.ERROR)
		reset_active()
		return
	end

	open_file_preview()
end

local function begin_next_request()
	if state.request_id or state.loading_request then
		return
	end

	local request = table.remove(state.queue, 1)
	if not request then
		return
	end

	begin_request(request)
end

local function enqueue_request(request)
	state.queue[#state.queue + 1] = request
	log(string.format("queued request %s (%d pending)", request.id, #state.queue))
end

local function apply_keymaps(buf)
	local maps = opts.keymaps
	local map_opts = { buffer = buf, nowait = true, silent = true }
	vim.keymap.set("n", maps.accept, function()
		vim.cmd("stopinsert")
		M.accept_file()
	end, vim.tbl_extend("force", map_opts, { desc = "Accept this preview file" }))
	vim.keymap.set("n", maps.accept_all, function()
		vim.cmd("stopinsert")
		M.accept_all()
	end, vim.tbl_extend("force", map_opts, { desc = "Accept entire OpenCode edit" }))
	vim.keymap.set("n", maps.reject, function()
		vim.cmd("stopinsert")
		M.reject_request()
	end, vim.tbl_extend("force", map_opts, { desc = "Reject OpenCode edit request" }))
	vim.keymap.set({ "n", "v" }, maps.comment, function()
		vim.cmd("stopinsert")
		send_review_comment()
	end, vim.tbl_extend("force", map_opts, { desc = "Send review note to OpenCode" }))
	vim.keymap.set("n", maps.close, function()
		vim.cmd("stopinsert")
		M.reject_request()
	end, vim.tbl_extend("force", map_opts, { desc = "Close preview and reject request" }))
	vim.keymap.set("n", "]c", function()
		M.next_hunk()
	end, vim.tbl_extend("force", map_opts, { desc = "Next review hunk" }))
	vim.keymap.set("n", "[c", function()
		M.prev_hunk()
	end, vim.tbl_extend("force", map_opts, { desc = "Previous review hunk" }))
end

local function jump_hunk(direction)
	if #state.hunk_lines == 0 then
		return
	end

	local current = vim.api.nvim_win_get_cursor(0)[1]
	local target
	if direction > 0 then
		for _, line in ipairs(state.hunk_lines) do
			if line > current then
				target = line
				break
			end
		end
		target = target or state.hunk_lines[1]
	else
		for i = #state.hunk_lines, 1, -1 do
			if state.hunk_lines[i] < current then
				target = state.hunk_lines[i]
				break
			end
		end
		target = target or state.hunk_lines[#state.hunk_lines]
	end

	vim.api.nvim_win_set_cursor(0, { target, 0 })
end

function M.next_hunk()
	jump_hunk(1)
end

function M.prev_hunk()
	jump_hunk(-1)
end

open_file_preview = function()
	local file = state.files[state.index]
	if not file then
		log("open_file_preview: no file at index " .. tostring(state.index))
		return
	end

	log(string.format("open_file_preview: index=%d count=%d file=%s", state.index, #state.files, file))

	local function ensure_tab()
		local function tab_is_usable()
			if not state.tab or not vim.api.nvim_tabpage_is_valid(state.tab) then
				return false
			end
			local wins = vim.api.nvim_tabpage_list_wins(state.tab)
			for _, w in ipairs(wins) do
				if vim.api.nvim_win_is_valid(w) then
					return true
				end
			end
			return false
		end
		if not tab_is_usable() then
			vim.cmd("tabnew")
			state.tab = vim.api.nvim_get_current_tabpage()
		end
	end

	ensure_tab()

	if state.buf and vim.api.nvim_buf_is_valid(state.buf) then
		vim.api.nvim_buf_delete(state.buf, { force = true })
	end
	state.buf = vim.api.nvim_create_buf(false, true)
	ensure_tab()
	local tab_wins = vim.api.nvim_tabpage_list_wins(state.tab)
	local win = tab_wins[1]
	if win and vim.api.nvim_win_is_valid(win) then
		vim.api.nvim_win_set_buf(win, state.buf)
	end

	local diff_lines = vim.fn.readfile(state.patch_file)
	local preview_lines, highlights, hunk_lines, line_kinds = render_diff(diff_lines, file)
	state.hunk_lines = hunk_lines
	state.line_kinds = line_kinds
	vim.bo[state.buf].buftype = "nofile"
	vim.bo[state.buf].bufhidden = "wipe"
	vim.bo[state.buf].swapfile = false
	vim.bo[state.buf].filetype = vim.filetype.match({ filename = file }) or ""
	vim.api.nvim_buf_set_name(state.buf, string.format("[opencode-review] %d/%d: %s", state.index, #state.files, file))
	vim.api.nvim_buf_set_lines(state.buf, 0, -1, false, preview_lines)
	for line, hl_group in pairs(highlights) do
		vim.api.nvim_buf_set_extmark(state.buf, ns, line - 1, 0, {
			line_hl_group = hl_group,
		})
	end
	vim.bo[state.buf].modifiable = false
	vim.wo.winbar = string.format("%%#DiagnosticInfo# OPENCODE REVIEW %%* %d/%d %s", state.index, #state.files, file)
	apply_keymaps(state.buf)
	if state.hunk_lines[1] then
		vim.api.nvim_win_set_cursor(0, { state.hunk_lines[1], 0 })
	end
	notify(string.format("Reviewing %d/%d: %s", state.index, #state.files, file))
end

function M.accept_file()
	if not state.request_id then
		log("accept_file: no active request")
		begin_next_request()
		return
	end

	local file = state.files[state.index]
	add_unique(state.accepted_files, file)

	for offset = 1, #state.files do
		local next_index = ((state.index - 1 + offset) % #state.files) + 1
		if not vim.tbl_contains(state.accepted_files, state.files[next_index]) then
			state.index = next_index
			open_file_preview()
			return
		end
	end

	M.accept_all()
end

function M.accept_all()
	if not state.request_id then
		log("accept_all: no active request")
		begin_next_request()
		return
	end

	local request_id = state.request_id
	log("accept_all: permitting request " .. request_id)
	for _, file in ipairs(state.accepted_files) do
		add_unique(state.approved_history, file)
	end
	reset_active()
	reply_permission(request_id, "once")
	begin_next_request()
end

function M.reject_request()
	if not state.request_id then
		log("reject_request: no active request")
		reset_active()
		begin_next_request()
		return
	end

	local request_id = state.request_id
	log("reject_request: rejecting request " .. request_id)
	reset_active()
	reply_permission(request_id, "reject")
	begin_next_request()
end

local function handle_event(event)
	local properties = event.properties or {}
	local metadata = properties.metadata or {}
	log(
		string.format(
			"event: type=%s permission=%s id=%s requestID=%s metadata_keys=%s",
			tostring(event.type),
			tostring(properties.permission),
			tostring(properties.id),
			tostring(properties.requestID),
			table.concat(vim.tbl_keys(metadata), ",")
		)
	)

	if event.type == "permission.replied" and state.request_id == event.properties.requestID then
		reset_active()
		begin_next_request()
		return
	end

	if event.type == "session.idle" then
		clear_review_batch()
		return
	end

	if event.type ~= "permission.asked" or event.properties.permission ~= "edit" then
		return
	end

	local diff = event.properties.metadata and event.properties.metadata.diff
	if not diff or diff == "" then
		log("permission.asked: no metadata.diff")
		return
	end

	local files = extract_files(event)
	log("permission.asked: extracted files=" .. table.concat(files, ","))
	if #files == 0 then
		notify("OpenCode edit request did not include file paths", vim.log.levels.WARN)
		return
	end

	local request = {
		id = event.properties.id,
		diff = diff,
		files = files,
	}

	if not state.batch_active and not state.request_id and not state.loading_request and #state.queue == 0 then
		log("start_review_batch")
		state.approved_history = {}
		state.approval_note_sent = false
		state.batch_active = true
	end

	if state.request_id or state.loading_request then
		enqueue_request(request)
		return
	end

	state.loading_request = true
	require("opencode.util").on_user_idle(opts.idle_delay_ms, function()
		log("permission.asked: idle callback")
		state.loading_request = false
		begin_request(request)
	end)
end

local function handle_permission_autocmd(args)
	handle_event(args.data.event)
end

local function schedule_reconnect()
	if state.reconnect_timer then
		return
	end
	state.reconnect_timer = vim.uv.new_timer()
	if not state.reconnect_timer then
		return
	end
	state.reconnect_timer:start(
		opts.reconnect_delay_ms,
		0,
		vim.schedule_wrap(function()
			state.reconnect_timer:stop()
			state.reconnect_timer:close()
			state.reconnect_timer = nil
			M.start()
		end)
	)
end

function M.stop()
	if state.event_job then
		vim.fn.jobstop(state.event_job)
		state.event_job = nil
	end
	if state.reconnect_timer then
		state.reconnect_timer:stop()
		state.reconnect_timer:close()
		state.reconnect_timer = nil
	end
end

function M.start()
	if state.event_job then
		return
	end

	local buffer = ""
	local url = endpoint("/event") .. "?directory=" .. vim.uri_encode(vim.fn.getcwd(), "rfc3986")
	log("start event stream: " .. url)
	state.event_job = vim.fn.jobstart({ "curl", "-N", "-sS", url }, {
		stdout_buffered = false,
		on_stdout = function(_, data)
			for _, chunk in ipairs(data or {}) do
				if chunk ~= "" then
					buffer = buffer .. chunk .. "\n"
					while true do
						local line, rest = buffer:match("^([^\n]*)\n(.*)$")
						if not line then
							break
						end
						buffer = rest
						local payload = line:match("^data:%s*(.+)$")
						if payload and payload ~= "[DONE]" then
							local ok, event = pcall(vim.json.decode, payload)
							if ok and type(event) == "table" then
								vim.schedule(function()
									handle_event(event)
								end)
							else
								log("failed to decode event payload: " .. payload)
							end
						end
					end
				end
			end
		end,
		on_stderr = function(_, data)
			local message = table.concat(data or {}, "")
			if message ~= "" then
				log("event stream stderr: " .. message)
			end
		end,
		on_exit = function(_, code)
			log("event stream exited: " .. tostring(code))
			state.event_job = nil
			schedule_reconnect()
		end,
	})

	if state.event_job <= 0 then
		log("failed to start event stream")
		state.event_job = nil
		schedule_reconnect()
	end
end

function M.setup(user_opts)
	opts = vim.tbl_deep_extend("force", vim.deepcopy(defaults), user_opts or {})
	log("setup")
	vim.api.nvim_create_user_command("OpencodeReviewAcceptFile", M.accept_file, { force = true })
	vim.api.nvim_create_user_command("OpencodeReviewReject", M.reject_request, { force = true })
	vim.api.nvim_create_user_command("OpencodeReviewComment", send_review_comment, { force = true, range = true })
	vim.api.nvim_create_user_command("OpencodeReviewStart", M.start, { force = true })
	vim.api.nvim_create_user_command("OpencodeReviewStop", M.stop, { force = true })

	vim.api.nvim_create_autocmd("User", {
		group = vim.api.nvim_create_augroup("OpencodeReview", { clear = true }),
		pattern = { "OpencodeEvent:permission.asked", "OpencodeEvent:permission.replied" },
		callback = handle_permission_autocmd,
		desc = "Review OpenCode edit permissions",
	})

	M.start()
end

return M
