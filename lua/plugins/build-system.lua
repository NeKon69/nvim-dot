_G.BuildSystem = _G.BuildSystem or {
	profile = "debug",
	available_profiles = { "debug", "release" },
}

return {
	"stevearc/overseer.nvim",
	lazy = false,
	opts = {
		-- Глобально используем jobstart для чистого вывода build/test
		strategy = "jobstart",
		form = { border = "rounded" },
		task_list = {
			direction = "bottom",
			min_height = 10,
			-- В документации раздел KEYMAPS:
			keymaps = {
				["q"] = "<CMD>close<CR>",
				["<CR>"] = "keymap.run_action",
				["L"] = "keymap.increase_detail",
				["H"] = "keymap.decrease_detail",
				["p"] = "keymap.toggle_preview",
				["dd"] = { "keymap.run_action", opts = { action = "dispose" }, desc = "Dispose" },
			},
		},
		component_aliases = {
			default = {
				-- display_duration УБРАН (вызывал warning)
				"on_exit_set_status",
				-- system = "never" (никакого спама на рабочий стол)
				{ "on_complete_notify", statuses = { "SUCCESS" }, system = "never" },
				{
					"on_output_quickfix",
					open = false,
					open_on_exit = "failure",
					focus = false,
					set_diagnostics = false, -- Никакой диагностики в коде
				},
			},
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		vim.notify("🏗️ Build System Ready", vim.log.levels.INFO)

		local function get_toml_tasks(opts)
			local files = vim.fs.find({ "overseer.toml", ".overseer.toml" }, { upward = true, type = "file" })
			if #files == 0 then
				return {}
			end

			local filename = files[1]
			local lines = vim.fn.readfile(filename)
			local tasks = {}
			local current_task = nil

			for _, line in ipairs(lines) do
				line = vim.trim(line)
				if line:match("^profiles%s*=") then
					local content = line:match("%[(.-)%]")
					if content then
						local profiles = {}
						for p in content:gmatch("[^,%s]+") do
							p = p:gsub("[\"']", "")
							table.insert(profiles, p)
						end
						_G.BuildSystem.available_profiles = profiles
					end
				elseif line:match("^%[") then
					if not line:match("^%[template%]") then
						local section = line:match("^%[boring_(%w+)%]") or line:match("^%[(%w+)%]")
						if section then
							current_task = {
								name = section,
								tags = { section:upper() },
								components = { "default" },
								cmd = "",
							}
							table.insert(tasks, current_task)
						end
					end
				elseif current_task and line ~= "" and not line:match("^#") then
					local key, value = line:match("^(%w+)%s*=%s*[\"']?(.-)[\"']?$")
					if key == "cmd" then
						current_task.cmd = value
					elseif key == "depends" then
						table.insert(current_task.components, {
							"dependencies",
							task_names = { { tags = { value:upper() } } },
						})
					end
				end
			end

			local templates = {}
			for _, t in ipairs(tasks) do
				table.insert(templates, {
					name = t.name,
					tags = t.tags,
					params = {
						profile = {
							type = "enum",
							choices = _G.BuildSystem.available_profiles,
							default = _G.BuildSystem.profile,
						},
						cmd = { type = "string", default = t.cmd },
					},
					builder = function(params)
						local final_cmd = params.cmd:gsub("{profile}", params.profile)
						local is_run = (t.name == "run")

						local components = vim.deepcopy(t.components)

						-- ИСПРАВЛЕНИЕ: Используем "dock" вместо "bottom" (согласно докам)
						if is_run then
							table.insert(components, {
								"open_output",
								direction = "dock",
								on_start = "always",
								focus = true,
							})
						end

						if final_cmd:match("^:") then
							return {
								name = string.format("%s (Vim)", t.name),
								cmd = "true",
								components = {
									"on_complete_notify",
									{
										"on_start",
										task_hook = function(task)
											vim.schedule(function()
												local ok, err = pcall(vim.cmd, final_cmd:sub(2))
												if not ok then
													vim.notify(err, 3)
												end
											end)
										end,
									},
								},
							}
						end

						return {
							cmd = final_cmd,
							-- ИСПРАВЛЕНИЕ: Используем формат таблицы для стратегии
							strategy = is_run and { "terminal" } or "jobstart",
							components = components,
							name = string.format("%s [%s]", t.name, params.profile),
						}
					end,
				})
			end
			return templates
		end

		overseer.register_template({
			name = "TOML Tasks",
			generator = function(opts, cb)
				cb(get_toml_tasks(opts))
			end,
		})
	end,
	keys = {
		{
			"<leader>bb",
			function()
				require("overseer").run_template({ name = "build" })
			end,
			desc = "🏗️ Build",
		},
		{
			"<leader>br",
			function()
				require("overseer").run_template({ name = "run" })
			end,
			desc = "🚀 Run",
		},
		{
			"<leader>bt",
			function()
				require("overseer").run_template({ name = "test" })
			end,
			desc = "🧪 Test",
		},
		{
			"<leader>bd",
			function()
				require("overseer").run_template({ name = "deploy" })
			end,
			desc = "📦 Deploy",
		},
		{
			"<leader>bc",
			function()
				require("overseer").run_template({ name = "clean" })
			end,
			desc = "🧹 Clean",
		},
		{ "<leader>bl", "<cmd>OverseerToggle bottom<cr>", desc = "📊 Task List" },
		{ "<leader>b.", "<cmd>OverseerRun<cr>", desc = "📋 All Tasks" },
		{
			"<leader>bP",
			function()
				vim.ui.select(_G.BuildSystem.available_profiles, { prompt = "Select Profile:" }, function(choice)
					if choice then
						_G.BuildSystem.profile = choice
						vim.notify("Profile: " .. choice)
					end
				end)
			end,
			desc = "🔀 Profile",
		},
	},
}
