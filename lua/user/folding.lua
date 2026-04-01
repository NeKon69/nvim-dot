local M = {}

local active_manual_folds = {}
local manual_fold_ranges = {}
local augroup = vim.api.nvim_create_augroup("UserFolding", { clear = true })
local config_dir = vim.fn.stdpath("config")
local pending_ufo_handler_retry = false
local folding_files = {
	[config_dir .. "/lua/user/folding.lua"] = true,
	[config_dir .. "/lua/plugins/folding.lua"] = true,
}

local function truncate_to_width(text, max_width)
	if max_width <= 0 then
		return ""
	end
	if vim.fn.strdisplaywidth(text) <= max_width then
		return text
	end

	local result = ""
	for _, char in ipairs(vim.fn.split(text, [[\zs]])) do
		local next_text = result .. char
		if vim.fn.strdisplaywidth(next_text) > max_width then
			break
		end
		result = next_text
	end
	return result
end

local function apply_window_fold_opts(winid)
	if not vim.api.nvim_win_is_valid(winid) then
		return
	end
	local bufnr = vim.api.nvim_win_get_buf(winid)
	if vim.bo[bufnr].buftype ~= "" then
		return
	end

	vim.wo[winid].foldcolumn = "1"
	vim.wo[winid].foldmethod = "manual"
	vim.wo[winid].foldtext = package.loaded["ufo"] and "v:lua.require'ufo.main'.foldtext()" or "v:lua.custom_foldtext()"
	vim.wo[winid].foldenable = true
	vim.wo[winid].foldlevel = 99
end

local function apply_ufo_handlers()
	if package.loaded["ufo"] then
		local ufo = require("ufo")
		local ok = true
		for _, bufnr in ipairs(vim.api.nvim_list_bufs()) do
			if vim.bo[bufnr].buftype == "" then
				local bound = pcall(ufo.setFoldVirtTextHandler, bufnr, M.ufo_fold_virt_text_handler)
				ok = ok and bound
			end
		end
		if not ok and not pending_ufo_handler_retry then
			pending_ufo_handler_retry = true
			vim.defer_fn(function()
				pending_ufo_handler_retry = false
				pcall(apply_ufo_handlers)
			end, 50)
		end
	end
end

local function refresh_all_fold_windows()
	for _, winid in ipairs(vim.api.nvim_list_wins()) do
		apply_window_fold_opts(winid)
	end
	apply_ufo_handlers()
end

local function first_nonblank_in_fold(start_line, end_line)
	for line_nr = start_line, end_line do
		local text = vim.trim(vim.fn.getline(line_nr))
		if text ~= "" then
			return text, line_nr
		end
	end

	return vim.trim(vim.fn.getline(start_line)), start_line
end

local function normalize_signature_text(text)
	if type(text) ~= "string" then
		return ""
	end
	text = text:gsub("%s+", " ")
	text = vim.trim(text)
	text = text:gsub("%s*{%s*$", "")
	return vim.trim(text)
end

local function strip_trailing_body_marker(text)
	text = text:gsub("%s+", " ")
	text = text:gsub("%s*{%s*$", "")
	return text
end

local function collapse_ws(text)
	return text:gsub("%s+", " ")
end

local function should_merge_signature_lines(start_line_text)
	start_line_text = vim.trim(start_line_text or "")
	if start_line_text == "" then
		return false
	end
	if start_line_text:find("namespace", 1, true) == 1 then
		return false
	end
	if start_line_text:find("class", 1, true) == 1 or start_line_text:find("struct", 1, true) == 1 then
		return false
	end
	return start_line_text:find("%(", 1, false) ~= nil
		or start_line_text:find("function", 1, true) ~= nil
		or start_line_text:find("::", 1, true) ~= nil
end

local function collect_signature_chunks(virt_text, lnum, end_lnum, ctx)
	local collected = {}
	local paren_depth = 0
	local saw_paren = false
	local last_was_space = true
	local merge_lines = should_merge_signature_lines(vim.fn.getline(lnum))

	local function push_text(text, hl)
		text = collapse_ws(text)
		if text == "" then
			return
		end
		if last_was_space then
			text = text:gsub("^ ", "")
		end
		text = strip_trailing_body_marker(text)
		if text == "" then
			return
		end

		for ch in text:gmatch(".") do
			if ch == "(" then
				saw_paren = true
				paren_depth = paren_depth + 1
			elseif ch == ")" then
				paren_depth = math.max(paren_depth - 1, 0)
			end
		end

		last_was_space = text:sub(-1) == " "
		table.insert(collected, { text, hl })
	end

	for line_nr = lnum, end_lnum do
		if line_nr > lnum and not merge_lines then
			break
		end
		local line_chunks
		if line_nr == lnum then
			line_chunks = virt_text
		elseif ctx and type(ctx.get_fold_virt_text) == "function" then
			line_chunks = ctx.get_fold_virt_text(line_nr)
		else
			line_chunks = { { vim.fn.getline(line_nr), "UfoFoldedFg" } }
		end
		for _, chunk in ipairs(line_chunks or {}) do
			push_text(chunk[1], chunk[2])
		end
		if saw_paren and paren_depth == 0 then
			break
		end
		push_text(" ", "UfoFoldedBg")
		if line_nr - lnum >= 12 then
			break
		end
	end

	return collected
end

local function is_body_node(node_type)
	return node_type == "body"
		or node_type == "block"
		or node_type == "block_statement"
		or node_type == "compound_statement"
		or node_type == "declaration_list"
		or node_type == "statement_block"
		or node_type == "function_body"
		or node_type == "class_body"
		or node_type == "field_declaration_list"
end

local function get_node_text_range(bufnr, start_row, start_col, end_row, end_col)
	local lines = vim.api.nvim_buf_get_text(bufnr, start_row, start_col, end_row, end_col, {})
	return table.concat(lines, " ")
end

local function get_treesitter_header(bufnr, start_line, end_line)
	local ok, result = pcall(function()
		local ok_parser, parser = pcall(vim.treesitter.get_parser, bufnr)
		if not ok_parser or not parser then
			return nil
		end

		local tree = parser:parse()[1]
		if not tree then
			return nil
		end

		local root = tree:root()
		local target = nil

		local function walk(node)
			local start_row, start_col, end_row, end_col = node:range()
			local node_start = start_row + 1
			local node_end = end_row + 1
			if node_end < start_line or node_start > end_line then
				return
			end

			if is_function_node(node:type()) and node_start == start_line and node_end <= end_line then
				if not target then
					target = {
						node = node,
						start_row = start_row,
						start_col = start_col,
						end_row = end_row,
						end_col = end_col,
					}
				else
					local target_span = target.end_row - target.start_row
					local node_span = end_row - start_row
					if node_span < target_span then
						target = {
							node = node,
							start_row = start_row,
							start_col = start_col,
							end_row = end_row,
							end_col = end_col,
						}
					end
				end
			end

			for child in node:iter_children() do
				walk(child)
			end
		end

		walk(root)
		if not target then
			return nil
		end

		local body = nil
		for child in target.node:iter_children() do
			if is_body_node(child:type()) then
				body = child
				break
			end
		end

		if body then
			local body_row, body_col = body:start()
			return normalize_signature_text(
				get_node_text_range(bufnr, target.start_row, target.start_col, body_row, body_col)
			)
		end

		return normalize_signature_text(vim.treesitter.get_node_text(target.node, bufnr))
	end)
	if not ok then
		return nil
	end
	return result
end

local function collect_fold_header(bufnr, start_line, end_line)
	local ts_header = get_treesitter_header(bufnr, start_line, end_line)
	if ts_header and ts_header ~= "" then
		return ts_header
	end

	local first_line, first_line_nr = first_nonblank_in_fold(start_line, end_line)
	local parts = { first_line }
	local saw_paren = first_line:find("%(", 1, false) ~= nil
	local paren_depth = 0

	for _, part in ipairs(parts) do
		for char in part:gmatch(".") do
			if char == "(" then
				paren_depth = paren_depth + 1
			elseif char == ")" then
				paren_depth = math.max(paren_depth - 1, 0)
			end
		end
	end

	if saw_paren and paren_depth == 0 then
		return normalize_signature_text(table.concat(parts, " "))
	end

	for line_nr = first_line_nr + 1, end_line do
		local text = vim.trim(vim.fn.getline(line_nr))
		if text ~= "" then
			table.insert(parts, text)
			for char in text:gmatch(".") do
				if char == "(" then
					saw_paren = true
					paren_depth = paren_depth + 1
				elseif char == ")" then
					paren_depth = math.max(paren_depth - 1, 0)
				end
			end

			if saw_paren and paren_depth == 0 then
				break
			end
		end
	end

	return normalize_signature_text(table.concat(parts, " "))
end

local function build_fold_text(bufnr, start_line, end_line, width)
	local line = collect_fold_header(bufnr, start_line, end_line)
	local hidden_lines = math.max(end_line - start_line, 1)
	local suffix = string.format("  { %d lines hidden }", hidden_lines)
	local text_width = math.max(width - vim.fn.strdisplaywidth(suffix) - 1, 8)
	return truncate_to_width(line, text_width) .. suffix
end

function _G.custom_foldtext()
	local window_width = vim.api.nvim_win_get_width(0)
	local number_width = vim.wo.number and math.max(vim.fn.strwidth(tostring(vim.fn.line("$"))), vim.wo.numberwidth)
		or 0
	local sign_width = vim.wo.signcolumn == "no" and 0 or 2
	local fold_column_width = tonumber((vim.wo.foldcolumn or "0"):match("%d+")) or 0
	local available_width = math.max(window_width - number_width - sign_width - fold_column_width - 1, 12)
	return build_fold_text(vim.api.nvim_get_current_buf(), vim.v.foldstart, vim.v.foldend, available_width)
end

function M.ufo_fold_virt_text_handler(virt_text, lnum, end_lnum, width, truncate, ctx)
	local hidden_lines = math.max(end_lnum - lnum, 1)
	local suffix = string.format("  { %d lines hidden }", hidden_lines)
	local suffix_width = vim.fn.strdisplaywidth(suffix)
	local target_width = math.max(width - suffix_width, 8)
	local source_chunks = collect_signature_chunks(virt_text, lnum, end_lnum, ctx)
	local new_virt_text = {}
	local current_width = 0

	for _, chunk in ipairs(source_chunks) do
		local chunk_text = strip_trailing_body_marker(chunk[1])
		local chunk_width = vim.fn.strdisplaywidth(chunk_text)
		if current_width + chunk_width <= target_width then
			if chunk_text ~= "" then
				table.insert(new_virt_text, { chunk_text, chunk[2] })
				current_width = current_width + chunk_width
			end
		else
			chunk_text = truncate(chunk_text, target_width - current_width)
			chunk_text = strip_trailing_body_marker(chunk_text)
			if chunk_text ~= "" then
				table.insert(new_virt_text, { chunk_text, chunk[2] })
				current_width = current_width + vim.fn.strdisplaywidth(chunk_text)
			end
			break
		end
	end

	table.insert(new_virt_text, { suffix, "Comment" })
	return new_virt_text
end

function M.ufo_opts()
	return {
		override_foldtext = true,
		enable_get_fold_virt_text = true,
		provider_selector = function()
			return ""
		end,
		fold_virt_text_handler = M.ufo_fold_virt_text_handler,
	}
end

function M.refresh_ufo_renderer()
	if package.loaded["ufo"] then
		require("ufo").setup(M.ufo_opts())
	end
	refresh_all_fold_windows()
end

local function is_function_node(node_type)
	return node_type:find("function", 1, true)
		or node_type:find("method", 1, true)
		or node_type:find("lambda", 1, true)
		or node_type:find("constructor", 1, true)
		or node_type:find("destructor", 1, true)
end

local function is_container_node(node_type)
	return node_type:find("namespace", 1, true)
		or node_type:find("module", 1, true)
		or node_type:find("class", 1, true)
		or node_type:find("struct", 1, true)
		or node_type:find("interface", 1, true)
		or node_type:find("impl", 1, true)
		or node_type:find("package", 1, true)
		or node_type:find("object", 1, true)
end

local function get_current_container(bufnr)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, ignore_injections = false })
	if not ok or not node then
		return nil
	end

	while node do
		if is_container_node(node:type()) then
			local start_row, _, end_row, _ = node:range()
			return {
				node = node,
				start_line = start_row + 1,
				end_line = end_row + 1,
			}
		end
		node = node:parent()
	end

	return nil
end

local function collect_ts_ranges(bufnr, container, include_containers)
	local ok, parser = pcall(vim.treesitter.get_parser, bufnr)
	if not ok or not parser then
		return {}
	end

	local tree = parser:parse()[1]
	if not tree then
		return {}
	end

	local result = {}
	local root = container.node or tree:root()

	local function walk(node)
		local start_row, _, end_row, _ = node:range()
		local start_line = start_row + 1
		local end_line = end_row + 1

		if end_line < container.start_line or start_line > container.end_line then
			return
		end

		local node_type = node:type()
		local matches = is_function_node(node_type) or (include_containers and is_container_node(node_type))
		if
			matches
			and start_line >= container.start_line
			and end_line <= container.end_line
			and end_line > start_line
		then
			table.insert(result, {
				start_line = start_line,
				end_line = end_line,
			})
		end

		for child in node:iter_children() do
			walk(child)
		end
	end

	walk(root)
	return result
end

local function get_current_structural_node(bufnr)
	local ok, node = pcall(vim.treesitter.get_node, { bufnr = bufnr, ignore_injections = false })
	if not ok or not node then
		return nil
	end

	while node do
		local node_type = node:type()
		if is_function_node(node_type) or is_container_node(node_type) then
			local start_row, _, end_row, _ = node:range()
			if end_row > start_row then
				return {
					node = node,
					start_line = start_row + 1,
					end_line = end_row + 1,
				}
			end
		end
		node = node:parent()
	end

	return nil
end

local function get_lsp_ranges(bufnr, container)
	local clients = vim.lsp.get_clients({ bufnr = bufnr, method = "textDocument/foldingRange" })
	if vim.tbl_isempty(clients) then
		return {}
	end

	local params = { textDocument = vim.lsp.util.make_text_document_params(bufnr) }
	local responses = vim.lsp.buf_request_sync(bufnr, "textDocument/foldingRange", params, 80)
	local ranges = {}

	for _, response in pairs(responses or {}) do
		for _, item in ipairs(response.result or {}) do
			local start_line = (item.startLine or 0) + 1
			local end_line = (item.endLine or 0) + 1
			if start_line >= container.start_line and end_line <= container.end_line and end_line > start_line then
				table.insert(ranges, {
					start_line = start_line,
					end_line = end_line,
				})
			end
		end
	end

	return ranges
end

local function same_range(a, b)
	return a.start_line == b.start_line and a.end_line == b.end_line
end

local function overlaps(a, b)
	return a.start_line <= b.end_line and b.start_line <= a.end_line
end

local function dedupe_ranges(ranges)
	table.sort(ranges, function(a, b)
		if a.start_line == b.start_line then
			return a.end_line > b.end_line
		end
		return a.start_line < b.start_line
	end)

	local deduped = {}
	for _, range in ipairs(ranges) do
		local previous = deduped[#deduped]
		if not previous or not same_range(previous, range) then
			table.insert(deduped, range)
		end
	end

	return deduped
end

local function pick_target_ranges(bufnr, container)
	local ts_ranges = collect_ts_ranges(bufnr, container, false)
	if vim.tbl_isempty(ts_ranges) then
		return {}
	end

	local final = {}
	local lsp_ranges = get_lsp_ranges(bufnr, container)

	for _, lsp_range in ipairs(lsp_ranges) do
		for _, ts_range in ipairs(ts_ranges) do
			if same_range(lsp_range, ts_range) or overlaps(lsp_range, ts_range) then
				table.insert(final, {
					start_line = math.max(lsp_range.start_line, ts_range.start_line),
					end_line = math.min(lsp_range.end_line, ts_range.end_line),
				})
				break
			end
		end
	end

	for _, ts_range in ipairs(ts_ranges) do
		local matched = false
		for _, picked in ipairs(final) do
			if same_range(ts_range, picked) then
				matched = true
				break
			end
		end
		if not matched then
			table.insert(final, ts_range)
		end
	end

	return dedupe_ranges(final)
end

local function collect_all_ranges(bufnr)
	local full_buffer = {
		start_line = 1,
		end_line = vim.api.nvim_buf_line_count(bufnr),
	}

	local lsp_ranges = dedupe_ranges(get_lsp_ranges(bufnr, full_buffer))
	if not vim.tbl_isempty(lsp_ranges) then
		return lsp_ranges
	end

	return dedupe_ranges(collect_ts_ranges(bufnr, full_buffer, true))
end

local function get_toggle_ranges(bufnr)
	local container = get_current_container(bufnr)
	local ranges = container and pick_target_ranges(bufnr, container) or {}
	if vim.tbl_isempty(ranges) then
		ranges = collect_all_ranges(bufnr)
	end
	return ranges
end

local function get_current_toggle_range(bufnr)
	local cursor_line = vim.api.nvim_win_get_cursor(0)[1]
	local best = nil

	for _, range in ipairs(get_toggle_ranges(bufnr)) do
		if range.start_line <= cursor_line and range.end_line >= cursor_line then
			if not best or range.start_line > best.start_line then
				best = range
			end
		end
	end

	return best
end

local function clear_manual_folds(bufnr)
	active_manual_folds[bufnr] = nil
	manual_fold_ranges[bufnr] = nil
	vim.cmd("silent! normal! zE")
	vim.cmd("silent! normal! zR")
end

local function clone_ranges(ranges)
	local cloned = {}
	for _, range in ipairs(ranges or {}) do
		table.insert(cloned, {
			start_line = range.start_line,
			end_line = range.end_line,
		})
	end
	return cloned
end

local function apply_folds(bufnr, ranges)
	local view = vim.fn.winsaveview()
	clear_manual_folds(bufnr)
	for _, range in ipairs(ranges) do
		vim.cmd(string.format("silent! %d,%dfold", range.start_line, range.end_line))
	end
	vim.fn.winrestview(view)
	active_manual_folds[bufnr] = true
	manual_fold_ranges[bufnr] = clone_ranges(ranges)
end

local function add_fold(bufnr, range)
	local view = vim.fn.winsaveview()
	vim.cmd(string.format("silent! %d,%dfold", range.start_line, range.end_line))
	vim.fn.winrestview(view)
	active_manual_folds[bufnr] = true
	manual_fold_ranges[bufnr] = clone_ranges(manual_fold_ranges[bufnr])
	table.insert(manual_fold_ranges[bufnr], {
		start_line = range.start_line,
		end_line = range.end_line,
	})
	manual_fold_ranges[bufnr] = dedupe_ranges(manual_fold_ranges[bufnr])
end

local function forget_opened_fold(bufnr, range)
	if not active_manual_folds[bufnr] or not range then
		return
	end

	local remaining = {}
	for _, candidate in ipairs(manual_fold_ranges[bufnr] or {}) do
		local contained = candidate.start_line >= range.start_line and candidate.end_line <= range.end_line
		if not contained then
			table.insert(remaining, candidate)
		end
	end

	if vim.tbl_isempty(remaining) then
		active_manual_folds[bufnr] = nil
		manual_fold_ranges[bufnr] = nil
		return
	end

	manual_fold_ranges[bufnr] = dedupe_ranges(remaining)
end

local function refresh_buffer_folds(bufnr)
	if not active_manual_folds[bufnr] then
		return
	end
	if bufnr ~= vim.api.nvim_get_current_buf() then
		return
	end
	local ranges = clone_ranges(manual_fold_ranges[bufnr])
	if vim.tbl_isempty(ranges) then
		return
	end
	local view = vim.fn.winsaveview()
	vim.cmd("silent! normal! zE")
	for _, range in ipairs(ranges) do
		vim.cmd(string.format("silent! %d,%dfold", range.start_line, range.end_line))
	end
	vim.fn.winrestview(view)
	if package.loaded["ufo"] then
		local ufo = require("ufo")
		pcall(ufo.detach, bufnr)
		pcall(ufo.attach, bufnr)
		pcall(ufo.setFoldVirtTextHandler, bufnr, M.ufo_fold_virt_text_handler)
	end
	vim.cmd("silent! redraw!")
end

function M.toggle()
	local bufnr = vim.api.nvim_get_current_buf()
	if active_manual_folds[bufnr] then
		clear_manual_folds(bufnr)
		return
	end

	local container = get_current_container(bufnr)
	local ranges = get_toggle_ranges(bufnr)
	if vim.tbl_isempty(ranges) then
		return
	end

	apply_folds(bufnr, ranges)
end

function M.open_current_fold_or_enter()
	local line = vim.fn.line(".")
	local start_line = vim.fn.foldclosed(line)
	if start_line ~= -1 then
		forget_opened_fold(vim.api.nvim_get_current_buf(), {
			start_line = start_line,
			end_line = vim.fn.foldclosedend(line),
		})
		return "zO"
	end

	return "<CR>"
end

function M.collapse_current_node()
	local bufnr = vim.api.nvim_get_current_buf()
	local range = get_current_structural_node(bufnr) or get_current_toggle_range(bufnr)
	if not range then
		return
	end

	add_fold(bufnr, range)
end

function M.open_all_folds()
	clear_manual_folds(vim.api.nvim_get_current_buf())
end

function M.setup()
	vim.api.nvim_clear_autocmds({ group = augroup })
	vim.opt.fillchars:append({
		fold = " ",
		foldopen = " ",
		foldclose = " ",
		foldsep = " ",
	})
	vim.o.foldmethod = "manual"
	vim.o.foldlevel = 99
	vim.o.foldlevelstart = 99
	vim.o.foldenable = true
	vim.o.foldcolumn = "1"
	vim.o.foldtext = "v:lua.custom_foldtext()"
	refresh_all_fold_windows()

	vim.keymap.set("n", "<CR>", M.open_current_fold_or_enter, {
		expr = true,
		desc = "Open Fold Or Enter",
	})
	vim.keymap.set("n", "<leader>uz", M.toggle, {
		desc = "󰘖 Toggle Container Functions",
	})
	vim.keymap.set("n", "<leader>uC", M.collapse_current_node, {
		desc = "Collapse Current Node",
	})
	vim.keymap.set("n", "<leader>uR", M.open_all_folds, {
		desc = "Open All Folds",
	})

	vim.api.nvim_create_autocmd({ "BufWinEnter", "WinEnter" }, {
		group = augroup,
		callback = function(args)
			apply_window_fold_opts(vim.api.nvim_get_current_win())
			vim.schedule(function()
				refresh_buffer_folds(args.buf)
			end)
		end,
	})

	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		callback = function(args)
			vim.schedule(function()
				refresh_buffer_folds(args.buf)
			end)
		end,
	})

	vim.api.nvim_create_autocmd({ "VimEnter", "SessionLoadPost" }, {
		group = augroup,
		callback = function()
			vim.schedule(refresh_all_fold_windows)
		end,
	})

	vim.api.nvim_create_autocmd("BufWritePost", {
		group = augroup,
		callback = function(args)
			local file = vim.fn.fnamemodify(args.file, ":p")
			if not folding_files[file] then
				return
			end

			package.loaded["user.folding"] = nil
			local ok, mod = pcall(require, "user.folding")
			if not ok then
				vim.notify(mod, vim.log.levels.ERROR)
				return
			end

			mod.setup()
			vim.schedule(mod.refresh_ufo_renderer)
			vim.cmd("silent! normal! zx")
			vim.notify("Folding config reloaded", vim.log.levels.INFO)
		end,
	})

	if vim.fn.exists(":FoldingReload") == 0 then
		vim.api.nvim_create_user_command("FoldingReload", function()
			package.loaded["user.folding"] = nil
			local mod = require("user.folding")
			mod.setup()
			vim.schedule(mod.refresh_ufo_renderer)
			vim.cmd("silent! normal! zx")
			vim.notify("Folding config reloaded", vim.log.levels.INFO)
		end, {})
	end
end

return M
