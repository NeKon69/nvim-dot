local M = {}

function M.setup()
	local user_template_dir = vim.fn.stdpath("config") .. "/templates/overseer"

	if vim.fn.isdirectory(user_template_dir) == 0 then
		vim.fn.mkdir(user_template_dir, "p")
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		callback = function()
			local cwd = vim.fn.getcwd()
			local target_config = cwd .. "/overseer.toml"

			if vim.fn.filereadable(target_config) == 1 then
				return
			end

			-- 2. Сканируем папку шаблонов
			local templates = vim.fn.glob(user_template_dir .. "/*.toml", false, true)

			for _, tmpl_path in ipairs(templates) do
				local lines = vim.fn.readfile(tmpl_path)

				local markers = {}
				local content_lines = {}
				local inside_template_block = false

				-- 3. Парсим файл: отделяем метадату [template] от контента
				for _, line in ipairs(lines) do
					local trimmed = vim.trim(line)

					if trimmed == "[template]" then
						inside_template_block = true
					elseif inside_template_block and trimmed:match("^markers") then
						-- Вытаскиваем список: markers = ["a", "b"]
						local list_str = trimmed:match("%[(.-)%]")
						if list_str then
							for m in list_str:gmatch("[\"'](.-)[\"']") do
								table.insert(markers, m)
							end
						end
					elseif inside_template_block and trimmed:match("^%[") then
						-- Началась следующая секция (например [build]), мета-блок закончился
						inside_template_block = false
						table.insert(content_lines, line)
					elseif not inside_template_block then
						-- Сохраняем строку полезного конфига
						table.insert(content_lines, line)
					end
				end

				-- 4. Если в файле вообще нет блока [template], используем имя файла как маркер (fallback)
				if #markers == 0 then
					local filename = vim.fn.fnamemodify(tmpl_path, ":t")
					table.insert(markers, filename) -- например "package.json"
				end

				-- 5. Проверяем маркеры в текущей директории
				local match_found = false
				for _, marker in ipairs(markers) do
					-- Используем glob, чтобы работали паттерны типа "*.cpp" или "src/main.rs"
					local found = vim.fn.glob(cwd .. "/" .. marker)
					if found ~= "" then
						match_found = true
						break
					end
				end

				-- 6. Если нашли совпадение — записываем файл
				if match_found then
					local file = io.open(target_config, "w")
					if file then
						file:write("# Auto-generated from template: " .. vim.fn.fnamemodify(tmpl_path, ":t") .. "\n")
						for _, line in ipairs(content_lines) do
							file:write(line .. "\n")
						end
						file:close()
						vim.notify("🚀 Created overseer.toml based on detected project type!", vim.log.levels.INFO)
					end
					return -- Прерываем цикл, первый подошедший шаблон выигрывает
				end
			end
		end,
	})
end

return M
