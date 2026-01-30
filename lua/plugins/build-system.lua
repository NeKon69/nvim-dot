_G.BuildSystem = _G.BuildSystem or {
	profile = "normal",
	available_profiles = {},
}

return {
	"stevearc/overseer.nvim",
	lazy = false,
	opts = {
		form = { border = "rounded" },
		task_list = {
			direction = "bottom",
			min_height = 10,
			keymaps = {
				["q"] = "<CMD>close<CR>",
				["<CR>"] = "keymap.run_action",
				["p"] = "keymap.toggle_preview",
				["<C-l>"] = function()
					local overseer = require("overseer")
					local tasks = overseer.list_tasks({ status = { "SUCCESS", "FAILURE", "CANCELED" } })
					for _, task in ipairs(tasks) do
						task:dispose()
					end
				end,
				["dd"] = { "keymap.run_action", opts = { action = "dispose" } },
			},
		},
		component_aliases = {
			default = {
				"on_exit_set_status",
				{ "on_complete_notify", statuses = { "SUCCESS" }, system = "never" },
				{
					"on_output_quickfix",
					open = false,
					open_on_exit = "failure",
					focus = false,
					set_diagnostics = false,
				},
			},
		},
	},
	config = function(_, opts)
		local overseer = require("overseer")
		overseer.setup(opts)

		vim.notify("🏗️ Build System Loaded", vim.log.levels.INFO)

		local function get_toml_tasks()
			local files = vim.fs.find({ "overseer.toml", ".overseer.toml" }, { upward = true, type = "file" })
			if #files == 0 then
				return {}
			end

			local filename = files[1]
			local lines = vim.fn.readfile(filename)
			local tasks_from_toml = {}
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
								depends_on = {},
							}
							table.insert(tasks_from_toml, current_task)
						end
					end
				elseif current_task and line ~= "" and not line:match("^#") then
					local key, value = line:match("^(%w+)%s*=%s*[\"']?(.-)[\"']?$")
					if key == "cmd" then
						current_task.cmd = value
					elseif key == "depends" then
						table.insert(current_task.depends_on, value)
					end
				end
			end

			local templates = {}
			for _, t in ipairs(tasks_from_toml) do
				table.insert(templates, {
					name = t.name,
					tags = t.tags,
					params = {
						profile = {
							type = "enum",
							choices = #_G.BuildSystem.available_profiles > 0 and _G.BuildSystem.available_profiles
								or { "normal" },
							default = _G.BuildSystem.profile,
						},
						cmd = { type = "string", default = t.cmd },
					},
					builder = function(params)
						local final_cmd = params.cmd:gsub("{profile}", params.profile)
						local is_run = (t.name == "run")

						local task_components = vim.deepcopy(t.components)

						if #t.depends_on > 0 then
							local dep_tasks = {}
							for _, dep_name in ipairs(t.depends_on) do
								table.insert(dep_tasks, {
									name = dep_name,
									params = { profile = params.profile },
								})
							end
							table.insert(task_components, { "dependencies", tasks = dep_tasks })
						end

						if is_run then
							return {
								cmd = "true",
								strategy = "jobstart",
								components = task_components,
								metadata = {
									is_interactive = true,
									interactive_cmd_str = final_cmd,
								},
								name = string.format("%s [%s]", t.name, params.profile),
							}
						else
							return {
								cmd = final_cmd,
								strategy = "jobstart",
								components = task_components,
								name = string.format("%s [%s]", t.name, params.profile),
							}
						end
					end,
				})
			end
			return templates
		end

		local toml_templates = get_toml_tasks()
		for _, template_def in ipairs(toml_templates) do
			overseer.register_template(template_def)
		end

		local run_fn = function()
			require("overseer").run_task({
				name = "run",
				params = { profile = _G.BuildSystem.profile },
			}, function(task)
				if task and task.metadata and task.metadata.is_interactive then
					local cmd_to_run = task.metadata.interactive_cmd_str
					vim.fn.timer_start(10, function()
						vim.cmd("terminal " .. vim.fn.shellescape(cmd_to_run))
					end, { ["repeat"] = 1 })
				end
			end)
		end
		vim.keymap.set("n", "<leader>br", run_fn, { desc = "▶️ Run" })
	end,
	keys = {
		{
			"<leader>bb",
			function()
				require("overseer").run_task({
					name = "build",
					params = { profile = _G.BuildSystem.profile },
				})
			end,
			desc = "🔨 Build",
		},
		{
			"<leader>bt",
			function()
				require("overseer").run_task({
					name = "test",
					params = { profile = _G.BuildSystem.profile },
				})
			end,
			desc = "🧪 Test",
		},
		{
			"<leader>bd",
			function()
				require("overseer").run_task({
					name = "deploy",
					params = { profile = _G.BuildSystem.profile },
				})
			end,
			desc = "🚀 Deploy",
		},
		{
			"<leader>bc",
			function()
				require("overseer").run_task({
					name = "clean",
					params = { profile = _G.BuildSystem.profile },
				})
			end,
			desc = "🧹 Clean",
		},
		{ "<leader>bl", "<cmd>OverseerToggle bottom<cr>", desc = "📋 Task List" },
		{ "<leader>b.", "<cmd>OverseerRun<cr>", desc = "📋 All Tasks" },
		{
			"<leader>bP",
			function()
				if #_G.BuildSystem.available_profiles == 0 then
					vim.notify("No profiles found in overseer.toml", vim.log.levels.WARN)
					return
				end
				vim.ui.select(_G.BuildSystem.available_profiles, { prompt = "Select Profile:" }, function(choice)
					if choice then
						_G.BuildSystem.profile = choice
						vim.notify("Build profile set to: " .. choice, vim.log.levels.INFO)
					end
				end)
			end,
			desc = "🔀 Profile",
		},
	},
}
