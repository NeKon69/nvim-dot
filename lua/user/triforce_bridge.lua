local M = {}

local data_path = vim.fn.stdpath("data") .. "/triforce_extra.json"

_G.TriforceExtra = {
	telescope_opened = 0,
	harpoon_switches = 0,
	dap_sessions = 0,
	undo_count = 0,
	git_commits = 0,
	total_commands = 0,
	compilations = 0,
	term_opens = 0,
	cuda_files_touched = 0,
	saves_count = 0,
}

local function load_extra()
	local f = io.open(data_path, "r")
	if f then
		local content = f:read("*a")
		f:close()
		local ok, decoded = pcall(vim.json.decode, content)
		if ok then
			for k, v in pairs(decoded) do
				_G.TriforceExtra[k] = v
			end
		end
	end
end

local function save_extra()
	local f = io.open(data_path, "w")
	if f then
		f:write(vim.json.encode(_G.TriforceExtra))
		f:close()
	end
end

local function inc(key)
	_G.TriforceExtra[key] = (_G.TriforceExtra[key] or 0) + 1
end

local group = vim.api.nvim_create_augroup("TriforceBridge", { clear = true })

-- --- 1. ТЕЛЕСКОП (Из твоего лога: TelescopeFindPre) ---
vim.api.nvim_create_autocmd("User", {
	pattern = "TelescopeFindPre",
	group = group,
	callback = function()
		inc("telescope_opened")
	end,
})

-- --- 2. HARPOON (Из твоего лога: FileType harpoon) ---
vim.api.nvim_create_autocmd("FileType", {
	pattern = "harpoon",
	group = group,
	callback = function()
		inc("harpoon_switches")
	end,
})

-- --- 3. OVERSEER И СБОРКА (Вклиниваемся в команды и ловим Output) ---
vim.api.nvim_create_autocmd("FileType", {
	pattern = "OverseerOutput",
	group = group,
	callback = function()
		inc("compilations")
	end,
})

-- --- 4. DAP / ОТЛАДКА (Из твоего лога: DapProgressUpdate) ---
-- Так как он стреляет часто, считаем только начало (когда появляется REPL или старт)
vim.api.nvim_create_autocmd("FileType", {
	pattern = "dap-repl",
	group = group,
	callback = function()
		inc("dap_sessions")
	end,
})

-- --- 5. ТЕРМИНАЛ (Из твоего лога: TermOpen + toggleterm) ---
vim.api.nvim_create_autocmd("TermOpen", {
	group = group,
	callback = function()
		inc("term_opens")
	end,
})

-- --- 6. CUDA Специфика ---
vim.api.nvim_create_autocmd("BufReadPost", {
	pattern = { "*.cu", "*.cuh" },
	group = group,
	callback = function()
		inc("cuda_files_touched")
	end,
})

-- --- 7. ГИТ (Коммиты) ---
vim.api.nvim_create_autocmd("FileType", {
	pattern = "gitcommit",
	group = group,
	callback = function()
		inc("git_commits")
	end,
})

-- --- 8. КОМАНДЫ (Вклиниваемся прямо в обработку командной строки) ---
vim.api.nvim_create_autocmd("CmdlineLeave", {
	group = group,
	callback = function()
		-- Проверяем, не была ли команда отменена (Esc)
		if vim.v.event.abort then
			return
		end

		inc("total_commands")
		local cmd = vim.fn.getcmdline()

		-- Если ты запустил OverseerRun или просто make
		if cmd:match("^Overseer") or cmd:match("^make") or cmd:match("^CMake") then
			inc("compilations")
		end
	end,
})

-- --- 9. ОТМЕНЫ (UNDO) ---
vim.on_key(function(key)
	if vim.api.nvim_get_mode().mode == "n" and key == "u" then
		inc("undo_count")
	end
end)

-- --- 10. СОХРАНЕНИЯ (Дополнительный трекинг) ---
vim.api.nvim_create_autocmd("BufWritePost", {
	group = group,
	callback = function()
		inc("saves_count")
	end,
})

-- Авто-сохранение данных раз в минуту и при выходе
local timer = vim.loop.new_timer()
timer:start(60000, 60000, vim.schedule_wrap(save_extra))
vim.api.nvim_create_autocmd("VimLeavePre", { group = group, callback = save_extra })

load_extra()

return M
