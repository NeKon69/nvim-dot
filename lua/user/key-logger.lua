-- ~/.config/nvim/lua/action_logger.lua (v11)

local M = {}

-- === Конфигурация ===
local COMMIT_DELAY = 700
local LOG_FILE_PATH = vim.fn.stdpath("data") .. "/neovim_actions_v11.jsonl"
-- ===

-- === Состояние логгера ===
local is_logging = false
local on_key_ns_id = nil
local augroup_id = nil
local key_sequence_buffer = {}
local insert_text_buffer = {}
local commit_timer = nil
-- ===

-- FIX: Правильная обработка возвращаемого значения nvim_win_get_cursor
local function get_current_context_snapshot()
	local context = {}
	local win_id = vim.api.nvim_get_current_win()
	local buf_nr = vim.api.nvim_win_get_buf(win_id)
	if not vim.api.nvim_buf_is_valid(buf_nr) then
		return nil
	end

	context.buffer_name = vim.api.nvim_buf_get_name(buf_nr)
	if context.buffer_name == "" then
		context.buffer_name = "[No Name]"
	end

	-- FIX: Вот он, корень зла. Правильно разбираем таблицу.
	local pos = vim.api.nvim_win_get_cursor(win_id) -- pos это {row, col}
	local row = pos[1]
	local col = pos[2]
	context.cursor = { line = row, col = col }

	context.mode = vim.api.nvim_get_mode().mode
	context.context_lines = {}
	local line_count = vim.api.nvim_buf_line_count(buf_nr)
	if line_count == 0 then
		return context
	end

	local context_size = 3
	local cursor_line_0based = row - 1 -- Теперь `row` это число, и все будет работать
	local start_line = math.max(0, cursor_line_0based - context_size)
	local end_line = math.min(line_count, cursor_line_0based + context_size + 1)

	if start_line >= end_line then
		return context
	end

	local success, lines = pcall(vim.api.nvim_buf_get_lines, buf_nr, start_line, end_line, false)
	if success then
		context.context_lines = lines
	end

	return context
end

-- Остальная часть файла не меняется, так как архитектура была верной,
-- а ошибка была в одной строчке интерпретации API.

local function log_entry(data)
	pcall(function()
		if not is_logging then
			return
		end
		data.timestamp = os.time()
		local json_entry = vim.fn.json_encode(data)
		local file = io.open(LOG_FILE_PATH, "a")
		if file then
			file:write(json_entry .. "\n")
			file:close()
		end
	end)
end

local function commit_and_log_sequence()
	if commit_timer and not commit_timer:is_closing() then
		commit_timer:close()
	end
	commit_timer = nil

	if #key_sequence_buffer > 0 then
		local context = get_current_context_snapshot()
		if not context then
			return
		end

		local sequence_str = ""
		for _, item in ipairs(key_sequence_buffer) do
			sequence_str = sequence_str .. item.key
		end
		local mode_at_start = key_sequence_buffer[1].mode
		key_sequence_buffer = {}

		log_entry({
			event_type = "key_sequence",
			sequence = sequence_str,
			mode = mode_at_start,
			buffer = context.buffer_name,
			cursor = context.cursor,
			context_lines = context.context_lines,
		})
	end
end

local function handle_insert_key(key)
	if key == "<BS>" then
		if #insert_text_buffer > 0 then
			table.remove(insert_text_buffer)
		end
	elseif key == "<CR>" or key == "<NL>" then
		table.insert(insert_text_buffer, "\n")
	elseif key == "<Tab>" then
		table.insert(insert_text_buffer, "    ")
	elseif #key == 1 then
		table.insert(insert_text_buffer, key)
	end
end

local function handle_key_press(key)
	pcall(function()
		local mode_info = vim.api.nvim_get_mode()
		local current_mode_str = mode_info.mode
		local readable_key = vim.api.nvim_replace_termcodes(key, true, true, true)

		if vim.tbl_contains({ "i", "R", "t" }, current_mode_str:sub(1, 1)) then
			handle_insert_key(readable_key)
		else
			if commit_timer and not commit_timer:is_closing() then
				commit_timer:close()
			end
			table.insert(key_sequence_buffer, { key = readable_key, mode = current_mode_str })
			commit_timer = vim.defer_fn(commit_and_log_sequence, COMMIT_DELAY)
		end
	end)
end

function M.clear_log()
	local file = io.open(LOG_FILE_PATH, "w")
	if file then
		file:close()
	end
	vim.notify("Файл логов очищен: " .. LOG_FILE_PATH)
end

function M.start()
	if is_logging then
		return
	end
	M.clear_log()
	is_logging = true
	on_key_ns_id = vim.on_key(handle_key_press)
	augroup_id = vim.api.nvim_create_augroup("ActionLoggerEvents", { clear = true })
	vim.api.nvim_create_autocmd("InsertEnter", {
		group = augroup_id,
		callback = function()
			commit_and_log_sequence()
			insert_text_buffer = {}
		end,
	})
	vim.api.nvim_create_autocmd("InsertLeave", {
		group = augroup_id,
		callback = function()
			if #insert_text_buffer > 0 then
				local context = get_current_context_snapshot()
				if not context then
					return
				end
				log_entry({
					event_type = "insert_text",
					text = table.concat(insert_text_buffer, ""),
					mode = context.mode,
					buffer = context.buffer_name,
					cursor = context.cursor,
					context_lines = context.context_lines,
				})
				insert_text_buffer = {}
			end
		end,
	})
	vim.api.nvim_create_autocmd("WinEnter", {
		group = augroup_id,
		callback = function()
			if not is_logging then
				return
			end
			commit_and_log_sequence()
			local context = get_current_context_snapshot()
			if not context then
				return
			end
			log_entry({
				event_type = "window_change",
				mode = context.mode,
				buffer = context.buffer_name,
				cursor = context.cursor,
				context_lines = context.context_lines,
			})
		end,
	})
	vim.notify("ActionLogger (v11) запущен.")
end

function M.stop()
	if not is_logging then
		return
	end
	commit_and_log_sequence()
	if on_key_ns_id then
		vim.on_key(nil, on_key_ns_id)
		on_key_ns_id = nil
	end
	if augroup_id then
		pcall(vim.api.nvim_del_augroup_by_id, augroup_id)
		augroup_id = nil
	end
	is_logging = false
	vim.notify("ActionLogger остановлен.")
end

return M
