local M = {}

function M.setup()
	local user_template_dir = vim.fn.stdpath("config") .. "/templates/overseer"

	if vim.fn.isdirectory(user_template_dir) == 0 then
		vim.fn.mkdir(user_template_dir, "p")
	end

	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		callback = function()
			local cwd = vim.fn.getcwd()
			local existing = vim.fs.find({ "justfile", ".justfile" }, { path = cwd, upward = false, type = "file" })
			if #existing > 0 then
				return
			end

			local templates = vim.fn.glob(user_template_dir .. "/*.just", false, true)

			for _, tmpl_path in ipairs(templates) do
				local lines = vim.fn.readfile(tmpl_path)
				local markers = {}
				local content_lines = {}

				for _, line in ipairs(lines) do
					local marker_list = line:match("^#%s*@markers:%s*(.*)")
					if marker_list then
						for m in marker_list:gmatch("[^,%s]+") do
							table.insert(markers, m)
						end
					else
						table.insert(content_lines, line)
					end
				end

				if #markers == 0 then
					local filename = vim.fn.fnamemodify(tmpl_path, ":t:r")
					table.insert(markers, filename)
				end

				local match_found = false
				for _, marker in ipairs(markers) do
					local found = vim.fn.glob(cwd .. "/" .. marker)
					if found ~= "" then
						match_found = true
						break
					end
				end

				if match_found then
					local target_path = cwd .. "/justfile"
					local file = io.open(target_path, "w")
					if file then
						file:write(
							"# Auto-generated justfile from template: " .. vim.fn.fnamemodify(tmpl_path, ":t") .. "\n\n"
						)
						for _, line in ipairs(content_lines) do
							file:write(line .. "\n")
						end
						file:close()

						pcall(function()
							require("overseer").clear_task_cache()
							if _G.BuildSystem and _G.BuildSystem.refresh_metadata then
								_G.BuildSystem.refresh_metadata()
							end
						end)

						vim.notify(
							"🛠️ Created 'justfile' for " .. vim.fn.fnamemodify(tmpl_path, ":t:r") .. " project!",
							vim.log.levels.INFO
						)
					end
					return
				end
			end
		end,
	})
end

return M
