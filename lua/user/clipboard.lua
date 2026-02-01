local M = {}

function M.copy_as_tag()
	-- 1. Получаем имя файла (только имя + расширение)
	local full_path = vim.api.nvim_buf_get_name(0)
	local filename = vim.fn.fnamemodify(full_path, ":t")
	if filename == "" then
		filename = "untitled"
	end

	-- 2. Определяем границы (весь файл или визуальное выделение)
	local mode = vim.api.nvim_get_mode().mode
	local start_line, end_line

	if mode:match("[vV]") then
		-- Если мы в визуальном режиме, берем границы выделения
		-- Используем v и . для получения меток начала и конца
		start_line = vim.fn.line("v")
		end_line = vim.fn.line(".")
		-- Если выделили снизу вверх, меняем местами
		if start_line > end_line then
			start_line, end_line = end_line, start_line
		end
		-- Выходим из визуального режима, чтобы выделение сбросилось визуально
		vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", true)
	else
		-- Иначе берем весь файл
		start_line = 1
		end_line = vim.api.nvim_buf_line_count(0)
	end

	-- 3. Получаем строки
	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	local content = table.concat(lines, "\n")

	-- 4. Формируем финальную строку
	local result = string.format('<file="%s">\n%s\n</file="%s">', filename, content, filename)

	-- 5. Копируем в системный буфер обмена (регистр "+")
	vim.fn.setreg("+", result)

	-- 6. Уведомление для кайфа
	local line_count = #lines
	vim.notify(string.format("Copied %d lines from %s", line_count, filename), vim.log.levels.INFO)
end

return M
