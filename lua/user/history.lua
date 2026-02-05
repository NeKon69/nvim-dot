local M = {}
local Path = require("plenary.path")

local root_markers = { ".git", "CMakeLists.txt", "Makefile", "package.json", "justfile" }
local last_recorded_pos = ""
local current_nav_idx = nil
local is_navigating = false -- Блокировщик записи при навигации

M.get_project_root = function()
	local current_file = vim.api.nvim_buf_get_name(0)
	local search_start = (current_file ~= "") and vim.fn.fnamemodify(current_file, ":p:h") or vim.fn.getcwd()
	local marker = vim.fs.find(root_markers, { upward = true, path = search_start })[1]
	if marker then
		local root = vim.fn.fnamemodify(marker, ":p:h")
		if root:match("%.git/?$") then
			root = vim.fn.fnamemodify(root, ":h")
		end
		return root
	end
	return vim.fn.getcwd()
end

M.record = function(action_name)
	if is_navigating then
		return
	end

	local winid = vim.api.nvim_get_current_win()
	local bufnr = vim.api.nvim_get_current_buf()

	-- 1. Игнорим плавающие окна (floating)
	local win_config = vim.api.nvim_win_get_config(winid)
	if win_config.relative ~= "" then
		return
	end

	-- 2. ГЛАВНЫЙ ФИЛЬТР: Игнорим всё, что не является обычным файлом
	-- У OverseerList, DAP-окон, NvimTree и терминалов buftype всегда НЕ пустой
	local buftype = vim.bo[bufnr].buftype
	if buftype ~= "" then
		return
	end

	-- 3. Дополнительный фильтр по filetype для окон, которые прикидываются обычными
	local filetype = vim.bo[bufnr].filetype
	local ft_ignore = {
		["OverseerList"] = true,
		["OverseerForm"] = true,
		["NvimTree"] = true,
		["undotree"] = true,
		["diff"] = true,
	}
	-- Игнорим если filetype в списке или начинается на dapui_
	if ft_ignore[filetype] or filetype:match("^dapui_") or filetype == "" then
		return
	end

	local file_path = vim.api.nvim_buf_get_name(bufnr)
	-- Проверяем, что это реальный путь на диске
	if file_path == "" or not (file_path:match("^/") or file_path:match("^[A-Z]:")) then
		return
	end

	local root = M.get_project_root()
	local cursor = vim.api.nvim_win_get_cursor(winid)

	-- Относительный путь (через pcall на всякий случай, чтобы не упасть если путь странный)
	local ok, rel_path = pcall(function()
		return Path:new(file_path):make_relative(root)
	end)
	if not ok or rel_path == nil then
		rel_path = file_path
	end

	local pos_id = string.format("%s:%d:%d", rel_path, cursor[1], cursor[2])

	if pos_id == last_recorded_pos then
		return
	end

	current_nav_idx = nil
	last_recorded_pos = pos_id

	local dot_nvim = Path:new(root, ".nvim")
	if not dot_nvim:exists() then
		dot_nvim:mkdir({ parents = true })
	end

	local history_file = dot_nvim:joinpath("history")
	local entry = string.format("%d|%s|%s|%d|%d\n", os.time(), action_name, rel_path, cursor[1], cursor[2])

	local f = io.open(history_file:expand(), "a")
	if f then
		f:write(entry)
		f:close()
	end
end

M.nav_history = function(direction)
	local root = M.get_project_root()
	local history_path = Path:new(root, ".nvim", "history")
	if not history_path:exists() then
		return
	end

	local lines = vim.fn.readfile(history_path:expand())
	lines = vim.tbl_filter(function(line)
		return line ~= ""
	end, lines)
	if #lines == 0 then
		return
	end

	-- Если начинаем навигацию впервые, ставим указатель на самый конец
	if current_nav_idx == nil then
		current_nav_idx = #lines
	end

	local new_idx = current_nav_idx + direction

	-- Проверка границ
	if new_idx < 1 then
		new_idx = 1
		vim.notify("Start of history", 1)
	elseif new_idx > #lines then
		new_idx = #lines
		vim.notify("End of history", 1)
	end

	if new_idx ~= current_nav_idx or direction == 0 then
		current_nav_idx = new_idx
		local parts = vim.split(lines[current_nav_idx], "|")
		local full_path = Path:new(root, parts[3]):expand()

		if vim.fn.filereadable(full_path) == 1 then
			-- Включаем режим навигации, чтобы record() проигнорировал этот переход
			is_navigating = true

			vim.cmd("e " .. full_path)
			vim.api.nvim_win_set_cursor(0, { tonumber(parts[4]), tonumber(parts[5]) })

			-- Выключаем режим навигации после того как все события отработают
			vim.schedule(function()
				is_navigating = false
				last_recorded_pos = string.format("%s:%s:%s", parts[3], parts[4], parts[5])
			end)
		end
	end
end

-- Остальное (wrap_jump, list_history) остается так же
M.wrap_jump = function(cmd, action)
	return function()
		M.record(action or "Jump")
		if type(cmd) == "string" then
			vim.cmd(cmd)
		else
			cmd()
		end
	end
end

M.list_history = function()
	local root = M.get_project_root()
	local history_path = Path:new(root, ".nvim", "history")
	if not history_path:exists() then
		return
	end
	local lines = vim.fn.readfile(history_path:expand())
	local reversed = {}
	for i = #lines, 1, -1 do
		if lines[i] ~= "" then
			table.insert(reversed, lines[i])
		end
	end

	require("telescope.pickers")
		.new({}, {
			prompt_title = "History: " .. vim.fn.fnamemodify(root, ":t"),
			finder = require("telescope.finders").new_table({
				results = reversed,
				entry_maker = function(entry)
					local parts = vim.split(entry, "|")
					return {
						value = entry,
						display = string.format(
							"[%s] %-10s │ %s:%s",
							os.date("%H:%M", tonumber(parts[1])),
							parts[2],
							parts[3],
							parts[4]
						),
						ordinal = entry,
						filename = root .. "/" .. parts[3],
						lnum = tonumber(parts[4]),
						col = tonumber(parts[5]),
					}
				end,
			}),
			previewer = require("telescope.config").values.file_previewer({}),
			sorter = require("telescope.config").values.generic_sorter({}),
		})
		:find()
end

local group = vim.api.nvim_create_augroup("ProjectHistory", { clear = true })
vim.api.nvim_create_autocmd("InsertEnter", {
	group = group,
	callback = function()
		M.record("Insert")
	end,
})
vim.api.nvim_create_autocmd("BufEnter", {
	group = group,
	callback = function()
		M.record("Switch")
	end,
})

return M
