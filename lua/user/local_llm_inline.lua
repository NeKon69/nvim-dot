local M = {}

local uv = vim.uv

local ns = vim.api.nvim_create_namespace("local_llm_inline")

local defaults = {
	server = {
		command = "llama-server",
		base_url = "http://127.0.0.1:8012",
		model = vim.fn.expand("~/Downloads/Qwen3.5-9B-Q6_K.gguf"),
		ctx_size = 8192,
		n_gpu_layers = 99,
		threads = -1,
		host = "127.0.0.1",
		port = 8012,
		timeout_s = 25,
		retries = 3,
		retry_backoff_ms = 1200,
		stop_on_exit = true,
		flash_attn = "on",
	},
	inference = {
		n_predict = 96,
		temperature = 0.6,
		top_p = 0.95,
		top_k = 20,
		repeat_penalty = 1.0,
		request_timeout_s = 10,
		max_tokens_context = 8192,
		prefix_chars = 5200,
		suffix_chars = 1800,
		nearby_lines = 220,
		type_depth = 2,
		related_files_max = 3,
		related_file_chars = 700,
		diagnostics_max = 8,
		edits_max = 60,
		lsp_cache_ttl_ms = 800,
		related_cache_ttl_ms = 2000,
		context_cache_ttl_ms = 1400,
		suggestion_cache_ttl_s = 30,
	},
	ui = {
		hl = "LocalLLMInlineGhost",
		first_delay_ms = 1000,
		second_delay_ms = 750,
	},
	keymaps = {
		accept = "<Tab>",
		accept_word = "<C-l>",
		next = "<M-j>",
		prev = "<M-k>",
		clear = "<M-;>",
	},
	state_file = vim.fn.stdpath("state") .. "/local_llm_inline_state.json",
	prompt = {
		system = "You are a code completion engine. Return only the missing code to insert at cursor. No markdown, no explanation.",
		build = nil,
	},
}

local state = {
	config = vim.deepcopy(defaults),
	server = {
		job = nil,
		pid = nil,
		watchdog_job = nil,
		healthy = false,
		starting = false,
		retries = 0,
	},
	timers = {
		first = nil,
		second = nil,
	},
	request = {
		first = nil,
		second = nil,
		generation = 0,
	},
	suggestions = {
		items = {},
		index = 1,
		snapshot = nil,
	},
	positions = {},
	edits = {},
	last_edit_tick = {},
	pending_insert = nil,
	initialized = false,
	last_server_warn = nil,
	cache = {
		lsp = {},
		related = {},
		context = {},
		ephemeral = {},
	},
}

local function notify(msg, level)
	local fn = function()
		vim.notify("LocalLLM: " .. msg, level or vim.log.levels.INFO)
	end
	if vim.in_fast_event() then
		vim.schedule(fn)
		return
	end
	fn()
end

local function deep_copy(v)
	return vim.deepcopy(v)
end

local function path_exists(path)
	return vim.uv.fs_stat(path) ~= nil
end

local function safe_decode(data)
	if not data or data == "" then
		return nil
	end
	local ok, decoded = pcall(vim.json.decode, data)
	if ok then
		return decoded
	end
	return nil
end

local function safe_encode(value)
	local ok, encoded = pcall(vim.json.encode, value)
	if ok then
		return encoded
	end
	return nil
end

local function cache_get(store, key, ttl_ms)
	local item = store[key]
	if not item then
		return nil
	end
	if (uv.now() - (item.ts or 0)) > ttl_ms then
		store[key] = nil
		return nil
	end
	return item.value
end

local function cache_set(store, key, value, max_entries)
	store[key] = { ts = uv.now(), value = value }
	local count = 0
	for _ in pairs(store) do
		count = count + 1
	end
	if count <= max_entries then
		return
	end
	local oldest_key, oldest_ts = nil, math.huge
	for k, v in pairs(store) do
		if (v.ts or 0) < oldest_ts then
			oldest_ts = v.ts or 0
			oldest_key = k
		end
	end
	if oldest_key then
		store[oldest_key] = nil
	end
end

local function clamp_chars_head(text, max_chars)
	if #text <= max_chars then
		return text
	end
	return text:sub(1, max_chars)
end

local function clamp_chars_tail(text, max_chars)
	if #text <= max_chars then
		return text
	end
	return text:sub(#text - max_chars + 1)
end

local function trim_empty_edges(lines)
	while #lines > 0 and vim.trim(lines[1]) == "" do
		table.remove(lines, 1)
	end
	while #lines > 0 and vim.trim(lines[#lines]) == "" do
		table.remove(lines, #lines)
	end
	return lines
end

local function get_buf_path(bufnr)
	local name = vim.api.nvim_buf_get_name(bufnr)
	if name == "" then
		return nil
	end
	return vim.fn.fnamemodify(name, ":p")
end

local function save_state_file()
	local payload = {
		positions = state.positions,
		edits = state.edits,
	}
	local encoded = safe_encode(payload)
	if not encoded then
		return
	end
	local path = state.config.state_file
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, err = pcall(vim.fn.writefile, vim.split(encoded, "\n", { plain = true }), path)
	if not ok then
		notify("failed to save state file: " .. tostring(err), vim.log.levels.WARN)
	end
end

local function load_state_file()
	local path = state.config.state_file
	if not path_exists(path) then
		return
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or not lines then
		return
	end
	local decoded = safe_decode(table.concat(lines, "\n"))
	if type(decoded) ~= "table" then
		return
	end
	state.positions = type(decoded.positions) == "table" and decoded.positions or {}
	state.edits = type(decoded.edits) == "table" and decoded.edits or {}
end

local function shell_post_json(url, payload, timeout_s, callback)
	local data = safe_encode(payload)
	if not data then
		callback(false, nil, "encode_failed")
		return function() end
	end

	local cmd = {
		"curl",
		"-sS",
		"--max-time",
		tostring(timeout_s),
		"-H",
		"Content-Type: application/json",
		"-X",
		"POST",
		url,
		"-d",
		data,
	}

	local canceled = false
	local proc = vim.system(cmd, { text = true }, function(res)
		if canceled then
			return
		end
		if res.code ~= 0 then
			callback(false, nil, res.stderr or "curl_failed")
			return
		end
		local parsed = safe_decode(res.stdout)
		callback(parsed ~= nil, parsed, parsed == nil and "decode_failed" or nil)
	end)

	return function()
		canceled = true
		pcall(function()
			proc:kill(15)
		end)
	end
end

local function shell_get_ok(url, timeout_s, callback)
	local cmd = {
		"curl",
		"-sS",
		"--max-time",
		tostring(timeout_s),
		url,
	}
	vim.system(cmd, { text = true }, function(res)
		callback(res.code == 0)
	end)
end

local function stop_timer(timer_id)
	if timer_id then
		pcall(vim.fn.timer_stop, timer_id)
	end
end

local function clear_timer(slot)
	stop_timer(state.timers[slot])
	state.timers[slot] = nil
end

local function clear_extmark(bufnr)
	if not bufnr or not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	pcall(vim.api.nvim_buf_clear_namespace, bufnr, ns, 0, -1)
end

local function snapshot_key(s)
	return string.format("%d:%d:%d:%d", s.bufnr, s.cursor[1], s.cursor[2], s.changedtick)
end

local function purge_ephemeral_cache()
	local ttl = state.config.inference.suggestion_cache_ttl_s or 30
	local now = os.time()
	for key, entry in pairs(state.cache.ephemeral) do
		if type(entry) ~= "table" or (now - (entry.ts or 0)) > ttl then
			state.cache.ephemeral[key] = nil
		end
	end
end

local function restore_ephemeral_suggestions(snap)
	purge_ephemeral_cache()
	if not snap then
		return false
	end
	local key = snapshot_key(snap)
	local entry = state.cache.ephemeral[key]
	if not entry or type(entry.items) ~= "table" or #entry.items == 0 then
		return false
	end
	entry.ts = os.time()
	state.suggestions.snapshot = deep_copy(snap)
	state.suggestions.items = deep_copy(entry.items)
	state.suggestions.index = math.max(1, math.min(entry.index or 1, #state.suggestions.items))
	return true
end

local function clear_suggestions(opts)
	opts = opts or {}
	purge_ephemeral_cache()
	local snap = state.suggestions.snapshot
	if opts.stash ~= false and snap and #state.suggestions.items > 0 then
		local key = snapshot_key(snap)
		state.cache.ephemeral[key] = {
			ts = os.time(),
			items = deep_copy(state.suggestions.items),
			index = state.suggestions.index,
		}
	end
	if snap and snap.bufnr then
		clear_extmark(snap.bufnr)
	end
	state.suggestions.items = {}
	state.suggestions.index = 1
	state.suggestions.snapshot = nil
end

local function cancel_requests()
	for _, key in ipairs({ "first", "second" }) do
		if state.request[key] then
			state.request[key]()
			state.request[key] = nil
		end
	end
end

local function is_insert_mode()
	local m = vim.fn.mode()
	return m == "i" or m == "R"
end

local function render_suggestion()
	if vim.in_fast_event() then
		vim.schedule(render_suggestion)
		return
	end

	local snap = state.suggestions.snapshot
	if not snap then
		return
	end
	if not vim.api.nvim_buf_is_valid(snap.bufnr) then
		return
	end
	clear_extmark(snap.bufnr)

	local text = state.suggestions.items[state.suggestions.index]
	if not text or text == "" then
		return
	end

	local row = snap.cursor[1] - 1
	local col = snap.cursor[2]
	local lines = vim.split(text, "\n", { plain = true })
	local virt_text = { { lines[1], state.config.ui.hl } }
	local opts = {
		virt_text = virt_text,
		virt_text_pos = "overlay",
		hl_mode = "combine",
		priority = 65535,
	}
	if #lines > 1 then
		local virt_lines = {}
		for i = 2, #lines do
			table.insert(virt_lines, { { lines[i], state.config.ui.hl } })
		end
		opts.virt_lines = virt_lines
	end

	vim.api.nvim_buf_set_extmark(snap.bufnr, ns, row, col, opts)
end

local function clean_completion(text)
	if not text then
		return ""
	end
	text = text:gsub("\r", "")
	text = text:gsub("<|fim_prefix|>", "")
	text = text:gsub("<|fim_suffix|>", "")
	text = text:gsub("<|fim_middle|>", "")
	text = text:gsub("<|im_end|>.*$", "")
	text = text:gsub("<|end|>.*$", "")
	text = text:gsub("^```[%w_%-]*\n", "")
	text = text:gsub("\n```$", "")
	text = text:gsub("^%s*Here is the completion:%s*", "")
	text = text:gsub("^%s*Completion:%s*", "")
	text = text:gsub("^%s*```[%w_%-]*", "")
	return text
end

local function trim_suffix_echo(text, suffix)
	if text == "" or suffix == "" then
		return text
	end
	local max = math.min(#text, #suffix)
	local overlap = 0
	for i = max, 1, -1 do
		if text:sub(1, i) == suffix:sub(1, i) then
			overlap = i
			break
		end
	end
	if overlap > 0 then
		text = text:sub(overlap + 1)
	end
	return text
end

local function add_suggestion(text)
	text = clean_completion(text)
	if text == "" then
		return false
	end
	for _, existing in ipairs(state.suggestions.items) do
		if existing == text then
			return false
		end
	end
	table.insert(state.suggestions.items, text)
	if #state.suggestions.items == 1 then
		state.suggestions.index = 1
	end
	return true
end

local function collect_symbols_summary(bufnr)
	local total = vim.api.nvim_buf_line_count(bufnr)
	local top_limit = math.min(total, 240)
	local lines = vim.api.nvim_buf_get_lines(bufnr, 0, top_limit, false)
	local picks = {}
	for _, line in ipairs(lines) do
		local l = vim.trim(line)
		if
			l:match('^#include%s+[<"].+[>"]')
			or l:match("^import%s+")
			or l:match("^from%s+[%w_%.]+%s+import%s+")
			or l:match("^local%s+[%w_]+%s*=%s*require")
			or l:match("^%s*class%s+[%w_]+")
			or l:match("^%s*struct%s+[%w_]+")
			or l:match("^%s*[%w_%*:&<>]+%s+[%w_:~]+%s*%b()%s*[%{;]")
		then
			table.insert(picks, l)
		end
		if #picks >= 80 then
			break
		end
	end
	return table.concat(trim_empty_edges(picks), "\n")
end

local function lsp_sync(method, params, timeout_ms)
	timeout_ms = timeout_ms or 180
	local bufnr = vim.api.nvim_get_current_buf()
	local pos = params and params.position or {}
	local tick = vim.b[bufnr].changedtick or 0
	local key =
		string.format("%s:%d:%d:%d:%d", method, bufnr, tick, (tonumber(pos.line) or 0), (tonumber(pos.character) or 0))
	local cached = cache_get(state.cache.lsp, key, state.config.inference.lsp_cache_ttl_ms)
	if cached ~= nil then
		return cached
	end
	local results = vim.lsp.buf_request_sync(bufnr, method, params, timeout_ms)
	if not results then
		cache_set(state.cache.lsp, key, false, 240)
		return nil
	end
	for _, item in pairs(results) do
		if item and item.result then
			cache_set(state.cache.lsp, key, item.result, 240)
			return item.result
		end
	end
	cache_set(state.cache.lsp, key, false, 240)
	return nil
end

local function collect_diagnostics(bufnr, row)
	local all = vim.diagnostic.get(bufnr)
	if #all == 0 then
		return ""
	end
	local max_diags = state.config.inference.diagnostics_max
	table.sort(all, function(a, b)
		return math.abs((a.lnum or 0) - (row - 1)) < math.abs((b.lnum or 0) - (row - 1))
	end)
	local out = {}
	for i = 1, math.min(max_diags, #all) do
		local d = all[i]
		local msg = tostring(d.message or "")
		msg = msg:gsub("\n", " ")
		table.insert(out, string.format("L%d:%d [%s] %s", (d.lnum or 0) + 1, (d.col or 0) + 1, d.source or "diag", msg))
	end
	return table.concat(out, "\n")
end

local function get_position_params(row, col)
	return {
		textDocument = { uri = vim.uri_from_bufnr(0) },
		position = {
			line = row - 1,
			character = col,
		},
	}
end

local function collect_hover_summary(row, col)
	local hover = lsp_sync("textDocument/hover", get_position_params(row, col), 220)
	if not hover then
		return ""
	end
	local c = hover.contents
	if type(c) == "string" then
		return c
	end
	if type(c) == "table" then
		if c.value then
			return tostring(c.value)
		end
		local parts = {}
		for _, v in ipairs(c) do
			if type(v) == "string" then
				table.insert(parts, v)
			elseif type(v) == "table" and v.value then
				table.insert(parts, tostring(v.value))
			end
		end
		return table.concat(parts, "\n")
	end
	return ""
end

local function collect_signature_summary(row, col)
	local sig = lsp_sync("textDocument/signatureHelp", get_position_params(row, col), 220)
	if not sig or not sig.signatures or #sig.signatures == 0 then
		return ""
	end
	local active = sig.signatures[(sig.activeSignature or 0) + 1] or sig.signatures[1]
	if not active then
		return ""
	end
	return tostring(active.label or "")
end

local function collect_definition_snippet(row, col)
	local def = lsp_sync("textDocument/definition", get_position_params(row, col), 220)
	if not def then
		return ""
	end
	local item = def[1] or def
	if not item then
		return ""
	end
	local uri = item.uri or item.targetUri
	local range = item.range or item.targetSelectionRange or item.targetRange
	if not uri or not range or not range.start then
		return ""
	end
	local target = vim.uri_to_fname(uri)
	if target == "" then
		return ""
	end
	local center = (range.start.line or 0) + 1
	local from_line = math.max(1, center - 8)
	local to_line = center + 10
	local lines = vim.fn.readfile(target)
	if not lines or #lines == 0 then
		return ""
	end
	local out = {}
	for i = from_line, math.min(to_line, #lines) do
		table.insert(out, lines[i])
	end
	return table.concat(out, "\n")
end

local function detect_expression_context(line_before_cursor)
	if line_before_cursor:match("%->$") or line_before_cursor:match("%.$") then
		return "member"
	end
	if line_before_cursor:match("%b()$") or line_before_cursor:match("%($") then
		return "call"
	end
	return "generic"
end

local function collect_type_context(row, col, line_before_cursor)
	local depth = state.config.inference.type_depth
	local chunks = {}
	table.insert(chunks, collect_hover_summary(row, col))
	if detect_expression_context(line_before_cursor) == "call" then
		table.insert(chunks, collect_signature_summary(row, col))
	end
	table.insert(chunks, collect_definition_snippet(row, col))

	for _ = 2, depth do
		table.insert(chunks, collect_hover_summary(row, col))
	end

	local merged = table.concat(chunks, "\n")
	return clamp_chars_head(merged, 1400)
end

local function parse_imports(lines)
	local imports = {}
	for _, line in ipairs(lines) do
		local quoted = line:match('#include%s+"([^"]+)"')
		if quoted then
			imports[vim.fn.fnamemodify(quoted, ":t")] = true
		end
		local req = line:match("require%([\"']([^\"']+)[\"']%)")
		if req then
			imports[vim.fn.fnamemodify(req, ":t") .. ".lua"] = true
		end
	end
	return imports
end

local function add_related_file_context(bufnr, row)
	local current = get_buf_path(bufnr)
	if not current then
		return ""
	end

	local line_count = vim.api.nvim_buf_line_count(bufnr)
	local top = vim.api.nvim_buf_get_lines(bufnr, 0, math.min(220, line_count), false)
	local imports = parse_imports(top)

	local candidates = {}
	for path, pos in pairs(state.positions) do
		if path ~= current and path_exists(path) then
			local score = 1
			local base = vim.fn.fnamemodify(path, ":t")
			if imports[base] then
				score = score + 3
			end
			if pos and pos.row then
				local dist = math.abs((pos.row or 1) - row)
				score = score + math.max(0, 2 - math.floor(dist / 80))
			end
			table.insert(
				candidates,
				{ path = path, score = score, ts = pos and pos.ts or 0, row = pos and pos.row or 1 }
			)
		end
	end

	table.sort(candidates, function(a, b)
		if a.score == b.score then
			return a.ts > b.ts
		end
		return a.score > b.score
	end)

	local out = {}
	for i = 1, math.min(#candidates, state.config.inference.related_files_max) do
		local c = candidates[i]
		local mtime = (uv.fs_stat(c.path) or {}).mtime
		local mt = type(mtime) == "table" and (mtime.sec or 0) or (mtime or 0)
		local cache_key = string.format("%s:%d:%d", c.path, c.row or 1, mt)
		local cached = cache_get(state.cache.related, cache_key, state.config.inference.related_cache_ttl_ms)
		if cached ~= nil then
			if cached ~= "" then
				table.insert(out, cached)
			end
		else
			local lines = vim.fn.readfile(c.path)
			if lines and #lines > 0 then
				local from_line = math.max(1, c.row - 10)
				local to_line = math.min(#lines, c.row + 14)
				local chunk = {}
				for li = from_line, to_line do
					table.insert(chunk, lines[li])
				end
				local text = clamp_chars_head(table.concat(chunk, "\n"), state.config.inference.related_file_chars)
				local formatted = string.format("[file:%s]\n%s", c.path, text)
				cache_set(state.cache.related, cache_key, formatted, 120)
				table.insert(out, formatted)
			else
				cache_set(state.cache.related, cache_key, "", 120)
			end
		end
	end

	return table.concat(out, "\n\n")
end

local function collect_recent_edits(path)
	local out = {}
	for i = #state.edits, 1, -1 do
		local e = state.edits[i]
		if e and e.path == path then
			table.insert(out, string.format("L%d %s", e.row or 1, e.text or ""))
		end
		if #out >= 12 then
			break
		end
	end
	return table.concat(out, "\n")
end

local function make_snapshot(opts)
	opts = opts or {}
	local deep_context = opts.deep_context == true
	local bufnr = vim.api.nvim_get_current_buf()
	if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].buftype ~= "" then
		return nil
	end
	local path = get_buf_path(bufnr)
	if not path then
		return nil
	end

	local cursor = vim.api.nvim_win_get_cursor(0)
	local row = cursor[1]
	local col = cursor[2]
	local line_count = vim.api.nvim_buf_line_count(bufnr)

	local nearby = state.config.inference.nearby_lines
	local from_line = math.max(1, row - nearby)
	local to_line = math.min(line_count, row + nearby)
	local lines = vim.api.nvim_buf_get_lines(bufnr, from_line - 1, to_line, false)

	local local_row = row - from_line + 1
	if local_row < 1 or local_row > #lines then
		return nil
	end

	local current_line = lines[local_row] or ""
	local head = current_line:sub(1, col)
	local tail = current_line:sub(col + 1)

	local prefix_lines = {}
	for i = 1, local_row - 1 do
		table.insert(prefix_lines, lines[i])
	end
	table.insert(prefix_lines, head)

	local suffix_lines = { tail }
	for i = local_row + 1, #lines do
		table.insert(suffix_lines, lines[i])
	end

	local prefix = clamp_chars_tail(table.concat(prefix_lines, "\n"), state.config.inference.prefix_chars)
	local suffix = clamp_chars_head(table.concat(suffix_lines, "\n"), state.config.inference.suffix_chars)

	local context_key = string.format(
		"%d:%d:%d:%d:%s",
		bufnr,
		row,
		col,
		(vim.b[bufnr].changedtick or 0),
		deep_context and "deep" or "light"
	)
	local context_blob = cache_get(state.cache.context, context_key, state.config.inference.context_cache_ttl_ms)
	if context_blob == nil then
		local diagnostics = collect_diagnostics(bufnr, row)
		local symbols = collect_symbols_summary(bufnr)
		local type_ctx = deep_context and collect_type_context(row, col, head) or ""
		local related = deep_context and add_related_file_context(bufnr, row) or ""
		local edits = collect_recent_edits(path)

		local sections = {
			"[SYSTEM] " .. state.config.prompt.system,
			"[TASK] inline completion at cursor; output only insertion",
			"[FILE] " .. path,
			"[LANG] " .. (vim.bo[bufnr].filetype or "text"),
			"[MODE] " .. (deep_context and "deep" or "light"),
			"[TYPE_CONTEXT]\n" .. type_ctx,
			"[DIAGNOSTICS]\n" .. diagnostics,
			"[SYMBOLS]\n" .. symbols,
			"[RECENT_EDITS]\n" .. edits,
			"[RELATED_FILES]\n" .. related,
		}
		context_blob = table.concat(sections, "\n\n")
		context_blob = clamp_chars_tail(context_blob, state.config.inference.max_tokens_context * 4)
		cache_set(state.cache.context, context_key, context_blob, 120)
	end

	return {
		bufnr = bufnr,
		path = path,
		cursor = { row, col },
		changedtick = vim.b[bufnr].changedtick,
		prefix = prefix,
		suffix = suffix,
		context = context_blob,
		head = head,
		deep_context = deep_context,
	}
end

local function parse_completion_response(json)
	if not json then
		return nil
	end
	if type(json.completion) == "string" then
		return json.completion
	end
	if type(json.content) == "string" then
		return json.content
	end
	if json.choices and json.choices[1] then
		local choice = json.choices[1]
		if type(choice.text) == "string" then
			return choice.text
		end
		if choice.message and type(choice.message.content) == "string" then
			return choice.message.content
		end
	end
	return nil
end

local function normalize_completion(snap, text)
	text = clean_completion(text or "")
	text = trim_suffix_echo(text, snap.suffix or "")
	if text == (snap.suffix or "") then
		return ""
	end
	return text
end

local function build_completion_prompt(snap)
	if type(state.config.prompt.build) == "function" then
		return state.config.prompt.build(snap)
	end
	local contract = {
		"You are an inline code completion model.",
		"Output only the code to insert at <|fim_middle|>.",
		"No markdown, no backticks, no prose, no surrounding quotes.",
		"Do not repeat content already present in suffix.",
		"Prefer concise continuation that compiles and matches local style.",
	}
	local context_block = table.concat({
		"/* INLINE_COMPLETION_CONTEXT",
		snap.context,
		"INLINE_COMPLETION_CONTEXT_END */",
	}, "\n")
	return table.concat({
		table.concat(contract, "\n"),
		"",
		"<|fim_prefix|>",
		context_block,
		snap.prefix,
		"<|fim_suffix|>",
		snap.suffix,
		"<|fim_middle|>",
	}, "\n")
end

local function request_with_fallback(snap, variation, cb)
	local inf = state.config.inference
	local base = state.config.server.base_url
	local temp = math.max(0.05, inf.temperature + variation)

	local prompt = build_completion_prompt(snap)
	local fim_payload = {
		prompt = prompt,
		n_predict = inf.n_predict,
		temperature = temp,
		top_p = inf.top_p,
		top_k = inf.top_k,
		repeat_penalty = inf.repeat_penalty,
		stream = false,
	}

	local canceled = false
	local cancel_first = shell_post_json(
		base .. "/v1/completions",
		fim_payload,
		inf.request_timeout_s,
		function(ok, json)
			if canceled then
				return
			end
			if ok then
				local parsed = normalize_completion(snap, parse_completion_response(json))
				if parsed and parsed ~= "" then
					cb(true, parsed)
					return
				end
			end

			local infill_payload = {
				input_prefix = snap.context .. "\n\n" .. snap.prefix,
				input_suffix = snap.suffix,
				n_predict = inf.n_predict,
				temperature = temp,
				top_p = inf.top_p,
				top_k = inf.top_k,
				repeat_penalty = inf.repeat_penalty,
			}

			shell_post_json(base .. "/infill", infill_payload, inf.request_timeout_s, function(ok2, json2)
				if canceled then
					return
				end
				if not ok2 then
					cb(false, nil)
					return
				end
				cb(true, normalize_completion(snap, parse_completion_response(json2)))
			end)
		end
	)

	return function()
		canceled = true
		cancel_first()
	end
end

local function cycle_suggestion(delta)
	if #state.suggestions.items <= 1 then
		return
	end
	local idx = state.suggestions.index + delta
	if idx < 1 then
		idx = #state.suggestions.items
	elseif idx > #state.suggestions.items then
		idx = 1
	end
	state.suggestions.index = idx
	render_suggestion()
end

local function current_suggestion()
	if #state.suggestions.items == 0 then
		return nil
	end
	return state.suggestions.items[state.suggestions.index]
end

function M._consume_pending_insert()
	local out = state.pending_insert or ""
	state.pending_insert = nil
	return out
end

local function consume_current_suggestion(prefix)
	local text = current_suggestion()
	if not text then
		return nil
	end
	if prefix and prefix ~= "" then
		text = text:sub(#prefix + 1)
	end
	if text == "" then
		clear_suggestions({ stash = false })
		return nil
	end
	clear_suggestions({ stash = false })
	return text
end

local function first_word_piece(text)
	local part = text:match("^%s*[%w_]+%s*")
	if part and part ~= "" then
		return part
	end
	return text:sub(1, 1)
end

function M.accept()
	local text = consume_current_suggestion("")
	if not text then
		return "\t"
	end
	state.pending_insert = text
	return '<C-g>u<C-R><C-O>=v:lua.require("user.local_llm_inline")._consume_pending_insert()<CR>'
end

function M.accept_word()
	local current = current_suggestion()
	if not current then
		return "<C-l>"
	end
	local part = first_word_piece(current)
	local text = current:sub(#part + 1)
	state.pending_insert = part
	if text ~= "" then
		state.suggestions.items[state.suggestions.index] = text
		render_suggestion()
	else
		clear_suggestions({ stash = false })
	end
	return '<C-g>u<C-R><C-O>=v:lua.require("user.local_llm_inline")._consume_pending_insert()<CR>'
end

function M.cycle_next()
	cycle_suggestion(1)
end

function M.cycle_prev()
	cycle_suggestion(-1)
end

function M.clear()
	clear_suggestions({ stash = false })
	cancel_requests()
	clear_timer("first")
	clear_timer("second")
end

local function apply_typed_char_hint(ch)
	local current = current_suggestion()
	if not current or not ch or ch == "" then
		return
	end
	local first = vim.fn.strcharpart(current, 0, 1)
	if first == ch then
		state.suggestions.items[state.suggestions.index] = vim.fn.strcharpart(current, 1)
		if state.suggestions.items[state.suggestions.index] == "" then
			clear_suggestions({ stash = false })
		else
			render_suggestion()
		end
	end
end

local function store_position(bufnr)
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
end

local function capture_edit(bufnr)
	if not vim.api.nvim_buf_is_valid(bufnr) then
		return
	end
	if vim.bo[bufnr].buftype ~= "" then
		return
	end
	local path = get_buf_path(bufnr)
	if not path then
		return
	end
	local tick = vim.b[bufnr].changedtick
	if state.last_edit_tick[bufnr] == tick then
		return
	end
	state.last_edit_tick[bufnr] = tick

	local cursor = vim.api.nvim_win_get_cursor(0)
	local from_line = math.max(1, cursor[1] - 2)
	local to_line = cursor[1] + 2
	local lines = vim.api.nvim_buf_get_lines(bufnr, from_line - 1, to_line, false)
	table.insert(state.edits, {
		path = path,
		row = cursor[1],
		tick = tick,
		text = table.concat(lines, "\\n"),
		ts = os.time(),
	})
	while #state.edits > state.config.inference.edits_max do
		table.remove(state.edits, 1)
	end
end

local function maybe_warn_server_unavailable()
	local now = os.time()
	if state.last_server_warn and (now - state.last_server_warn) < 8 then
		return
	end
	state.last_server_warn = now
	notify("llama server is not healthy yet", vim.log.levels.WARN)
end

local function request_completion(kind, snap, variation)
	if not state.server.healthy then
		maybe_warn_server_unavailable()
		return
	end

	state.request.generation = state.request.generation + 1
	local gen = state.request.generation

	if state.request[kind] then
		state.request[kind]()
		state.request[kind] = nil
	end

	state.request[kind] = request_with_fallback(snap, variation, function(ok, text)
		vim.schedule(function()
			if gen ~= state.request.generation then
				return
			end
			if not ok or not text or text == "" then
				return
			end
			if not state.suggestions.snapshot or snapshot_key(state.suggestions.snapshot) ~= snapshot_key(snap) then
				state.suggestions.snapshot = deep_copy(snap)
				state.suggestions.items = {}
				state.suggestions.index = 1
			end
			if add_suggestion(text) then
				render_suggestion()
			end
		end)
	end)
end

local function schedule_completions()
	if not is_insert_mode() then
		return
	end

	cancel_requests()
	clear_timer("first")
	clear_timer("second")

	state.timers.first = vim.fn.timer_start(state.config.ui.first_delay_ms, function()
		vim.schedule(function()
			if not is_insert_mode() then
				return
			end
			local current = make_snapshot({ deep_context = false })
			if not current then
				return
			end
			local restored = restore_ephemeral_suggestions(current)
			if restored then
				render_suggestion()
			else
				state.suggestions.snapshot = deep_copy(current)
				state.suggestions.items = {}
				state.suggestions.index = 1
			end
			request_completion("first", current, 0.0)

			state.timers.second = vim.fn.timer_start(state.config.ui.second_delay_ms, function()
				vim.schedule(function()
					if not is_insert_mode() then
						return
					end
					local second = make_snapshot({ deep_context = true })
					if not second then
						return
					end
					if snapshot_key(second) ~= snapshot_key(current) then
						return
					end
					request_completion("second", second, 0.12)
				end)
			end)
		end)
	end)
end

local function kill_job(job)
	if not job then
		return
	end
	pcall(function()
		job:kill(15)
	end)
end

local function spawn_watchdog(llama_pid)
	if not llama_pid or llama_pid <= 0 then
		return
	end
	kill_job(state.server.watchdog_job)
	local nvim_pid = uv.os_getpid()
	local cmd = string.format(
		"while kill -0 %d >/dev/null 2>&1; do sleep 2; done; kill -TERM %d >/dev/null 2>&1",
		nvim_pid,
		llama_pid
	)
	state.server.watchdog_job = vim.system({ "sh", "-c", cmd }, { text = true }, function() end)
end

local function set_server_unhealthy()
	state.server.healthy = false
	state.server.starting = false
end

local function check_health_and_mark(callback)
	shell_get_ok(state.config.server.base_url .. "/health", 1, function(ok)
		if ok then
			state.server.healthy = true
			state.server.starting = false
			callback(true)
		else
			callback(false)
		end
	end)
end

local function wait_until_healthy_or_retry()
	local deadline = uv.now() + (state.config.server.timeout_s * 1000)
	local function poll()
		check_health_and_mark(function(ok)
			if ok then
				notify("llama server is ready")
				return
			end
			if uv.now() > deadline then
				set_server_unhealthy()
				state.server.retries = state.server.retries + 1
				if state.server.retries >= state.config.server.retries then
					notify("llama server failed to start after retries", vim.log.levels.WARN)
					return
				end
				vim.defer_fn(function()
					M.start_server()
				end, state.config.server.retry_backoff_ms * state.server.retries)
				return
			end
			vim.defer_fn(poll, 300)
		end)
	end
	poll()
end

function M.start_server()
	if state.server.healthy or state.server.starting then
		return
	end

	local cfg = state.config.server
	if not path_exists(cfg.model) then
		notify("model not found: " .. cfg.model, vim.log.levels.ERROR)
		return
	end

	state.server.starting = true
	local cmd = {
		cfg.command,
		"-m",
		cfg.model,
		"--host",
		cfg.host,
		"--port",
		tostring(cfg.port),
		"--ctx-size",
		tostring(cfg.ctx_size),
		"--n-gpu-layers",
		tostring(cfg.n_gpu_layers),
		"--threads",
		tostring(cfg.threads),
	}
	if cfg.flash_attn then
		table.insert(cmd, "--flash-attn")
		if type(cfg.flash_attn) == "string" and cfg.flash_attn ~= "" then
			table.insert(cmd, cfg.flash_attn)
		else
			table.insert(cmd, "on")
		end
	end

	state.server.job = vim.system(cmd, { text = true }, function(res)
		set_server_unhealthy()
		if res.code ~= 0 then
			local err = vim.trim((res.stderr or ""):gsub("\n+", " "))
			if err ~= "" then
				notify("llama server exited (" .. tostring(res.code) .. "): " .. err, vim.log.levels.WARN)
			else
				notify("llama server exited (" .. tostring(res.code) .. ")", vim.log.levels.WARN)
			end
		end
	end)
	state.server.pid = state.server.job.pid
	spawn_watchdog(state.server.pid)
	wait_until_healthy_or_retry()
end

function M.stop_server()
	cancel_requests()
	clear_timer("first")
	clear_timer("second")
	kill_job(state.server.watchdog_job)
	state.server.watchdog_job = nil
	if state.server.job then
		kill_job(state.server.job)
		state.server.job = nil
	end
	state.server.pid = nil
	state.server.healthy = false
	state.server.starting = false
end

local function setup_highlights()
	local hl = state.config.ui.hl
	if not hl or hl == "" then
		return
	end
	if vim.o.termguicolors then
		local normal = vim.api.nvim_get_hl(0, { name = "Normal", link = false })
		local fg = normal and normal.fg and string.format("#%06x", normal.fg) or "#C0C8D6"
		vim.api.nvim_set_hl(0, hl, {
			fg = fg,
			bg = "NONE",
			italic = false,
			blend = 55,
			nocombine = false,
		})
	else
		vim.api.nvim_set_hl(0, hl, { ctermfg = 244, italic = false })
	end
end

local function setup_keymaps()
	local km = state.config.keymaps
	if km.accept and km.accept ~= "" then
		vim.keymap.set(
			"i",
			km.accept,
			M.accept,
			{ expr = true, silent = true, nowait = true, desc = "Local LLM accept" }
		)
	end
	if km.accept_word and km.accept_word ~= "" then
		vim.keymap.set(
			"i",
			km.accept_word,
			M.accept_word,
			{ expr = true, silent = true, nowait = true, desc = "Local LLM accept word" }
		)
	end
	if km.next and km.next ~= "" then
		vim.keymap.set("i", km.next, M.cycle_next, { silent = true, desc = "Local LLM next" })
	end
	if km.prev and km.prev ~= "" then
		vim.keymap.set("i", km.prev, M.cycle_prev, { silent = true, desc = "Local LLM prev" })
	end
	if km.clear and km.clear ~= "" then
		vim.keymap.set("i", km.clear, M.clear, { silent = true, desc = "Local LLM clear" })
	end
end

local function setup_autocmds()
	local group = vim.api.nvim_create_augroup("LocalLLMInline", { clear = true })

	vim.api.nvim_create_autocmd({ "InsertEnter", "BufEnter" }, {
		group = group,
		callback = function()
			schedule_completions()
		end,
	})

	vim.api.nvim_create_autocmd("TextChangedI", {
		group = group,
		callback = function(args)
			vim.schedule(function()
				capture_edit(args.buf)
				schedule_completions()
			end)
		end,
	})

	vim.api.nvim_create_autocmd("InsertCharPre", {
		group = group,
		callback = function()
			local ch = vim.v.char
			vim.schedule(function()
				apply_typed_char_hint(ch)
			end)
		end,
	})

	vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave" }, {
		group = group,
		callback = function(args)
			if args.buf and vim.api.nvim_buf_is_valid(args.buf) then
				store_position(args.buf)
			end
			clear_suggestions()
			cancel_requests()
			clear_timer("first")
			clear_timer("second")
			save_state_file()
		end,
	})

	vim.api.nvim_create_autocmd({ "VimEnter" }, {
		group = group,
		callback = function()
			setup_highlights()
			M.start_server()
		end,
	})

	vim.api.nvim_create_autocmd("ColorScheme", {
		group = group,
		callback = function()
			setup_highlights()
		end,
	})

	vim.api.nvim_create_autocmd({ "VimLeavePre" }, {
		group = group,
		callback = function()
			save_state_file()
			if state.config.server.stop_on_exit then
				M.stop_server()
			end
		end,
	})
end

function M.setup(opts)
	if state.initialized then
		return
	end
	state.config = vim.tbl_deep_extend("force", deep_copy(defaults), opts or {})
	load_state_file()
	setup_highlights()
	setup_keymaps()
	setup_autocmds()
	state.initialized = true
end

return M
