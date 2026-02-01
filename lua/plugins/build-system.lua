_G.BuildSystem = _G.BuildSystem
	or {
		profile = "normal",
		target = "Default",
		available_profiles = {},
		available_targets = {},
		overrides = {},
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

		local state_file = vim.fn.stdpath("state") .. "/overseer_profiles.json"
		local global_config_path = vim.fn.stdpath("config") .. "/lua/user/overseer_quick_run.lua"

		local function save_state()
			local data = {}
			if vim.fn.filereadable(state_file) == 1 then
				local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(state_file))
				if ok then
					data = decoded
				end
			end
			data[vim.fn.getcwd()] = {
				profile = _G.BuildSystem.profile,
				target = _G.BuildSystem.target,
			}
			vim.fn.writefile({ vim.fn.json_encode(data) }, state_file)
		end

		local function load_state()
			if vim.fn.filereadable(state_file) == 1 then
				local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(state_file))
				if ok and decoded[vim.fn.getcwd()] then
					local saved = decoded[vim.fn.getcwd()]
					if type(saved) == "string" then
						_G.BuildSystem.profile = saved
					elseif type(saved) == "table" then
						_G.BuildSystem.profile = saved.profile or "normal"
						_G.BuildSystem.target = saved.target or "Default"
					end
				end
			end
		end

		local function get_toml_tasks()
			local files = vim.fs.find({ "overseer.toml", ".overseer.toml" }, { upward = true, type = "file" })
			if #files == 0 then
				return {}, nil
			end

			local filename = files[1]
			local lines = vim.fn.readfile(filename)
			local tasks_from_toml = {}
			local current_task = nil
			local new_profiles = {}
			local new_targets = {}

			for _, line in ipairs(lines) do
				line = vim.trim(line)
				if line:match("^profiles%s*=") then
					local content = line:match("%[(.-)%]")
					if content then
						for p in content:gmatch("[^,%s]+") do
							table.insert(new_profiles, (p:gsub("[\"']", "")))
						end
						_G.BuildSystem.available_profiles = new_profiles
					end
				elseif line:match("^targets%s*=") then
					local content = line:match("%[(.-)%]")
					if content then
						for t in content:gmatch("[^,%s]+") do
							table.insert(new_targets, (t:gsub("[\"']", "")))
						end
						_G.BuildSystem.available_targets = new_targets
					end
				elseif line:match("^%[") then
					if not line:match("^%[template%]") then
						local section_content = line:match("^%[boring_([%w_.]+)%]") or line:match("^%[([%w_.]+)%]")
						if section_content then
							current_task = {
								raw_name = section_content,
								tags = { section_content:upper() },
								components = { "default" },
								cmd = "",
								depends_on = {},
								watch = false, -- по умолчанию выключено
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
					elseif key == "watch" then
						current_task.watch = (value == "true")
					end
				end
			end
			return tasks_from_toml, filename
		end

		local function refresh_build_system_metadata()
			local _, filename = get_toml_tasks()
			if filename then
				if _G.BuildSystem.target == "Default" and #_G.BuildSystem.available_targets > 0 then
					_G.BuildSystem.target = _G.BuildSystem.available_targets[1]
				end
			end
		end

		overseer.register_template({
			name = "toml_tasks_provider",
			generator = function(search, cb)
				refresh_build_system_metadata()
				local raw_tasks, _ = get_toml_tasks()
				local templates = {}
				local current_target = _G.BuildSystem.target

				for _, t in ipairs(raw_tasks) do
					local task_name = t.raw_name
					local is_visible = false
					local dot_pos = task_name:find("%.")

					if dot_pos then
						if task_name:sub(1, dot_pos - 1) == current_target then
							task_name = task_name:sub(dot_pos + 1)
							is_visible = true
						end
					else
						is_visible = true
					end

					if is_visible then
						table.insert(templates, {
							name = task_name,
							tags = t.tags,
							params = {
								profile = {
									type = "enum",
									choices = #_G.BuildSystem.available_profiles > 0
											and _G.BuildSystem.available_profiles
										or { "normal" },
									default = _G.BuildSystem.profile,
								},
								target = { type = "string", default = current_target },
							},
							builder = function(params)
								local override_cmd = _G.BuildSystem.overrides[t.raw_name]
									and _G.BuildSystem.overrides[t.raw_name][params.profile]

								local final_cmd = override_cmd or t.cmd
								final_cmd = final_cmd:gsub("{profile}", params.profile)
								final_cmd = final_cmd:gsub("{target}", params.target)

								local is_run = (task_name == "run")
								local task_components = vim.deepcopy(t.components)

								if #t.depends_on > 0 then
									local dep_tasks = {}
									for _, dep_name in ipairs(t.depends_on) do
										table.insert(dep_tasks, { dep_name, profile = params.profile })
									end
									table.insert(task_components, { "dependencies", tasks = dep_tasks })
								end

								-- Добавляем Watcher если включено
								if t.watch then
									table.insert(task_components, { "restart_on_save", paths = { vim.fn.getcwd() } })
								end

								local display_name
								if #_G.BuildSystem.available_targets > 0 then
									display_name = string.format("%s [%s:%s]", task_name, params.target, params.profile)
								else
									display_name = string.format("%s [%s]", task_name, params.profile)
								end

								return {
									cmd = is_run and "echo 'Launching terminal...'" or final_cmd,
									strategy = "jobstart",
									components = task_components,
									metadata = { real_cmd = final_cmd },
									name = display_name,
								}
							end,
						})
					end
				end
				cb(templates)
			end,
		})

		local build_sys_group = vim.api.nvim_create_augroup("BuildSystemAutoUpdate", { clear = true })
		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			group = build_sys_group,
			callback = function()
				load_state()
				refresh_build_system_metadata()
			end,
		})
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = build_sys_group,
			pattern = { "overseer.toml", ".overseer.toml" },
			callback = function()
				refresh_build_system_metadata()
				overseer.clear_task_cache()
				vim.notify("Overseer config reloaded", vim.log.levels.INFO)
			end,
		})

		local function run_task_by_name(name)
			overseer.run_task({
				name = name,
				params = { profile = _G.BuildSystem.profile },
			}, function(task)
				if not task then
					vim.notify(
						"Task '" .. name .. "' not found for target: " .. _G.BuildSystem.target,
						vim.log.levels.WARN
					)
					return
				end
				if name == "run" then
					task:subscribe("on_start", function()
						local cmd_to_run = task.metadata.real_cmd
						if cmd_to_run then
							require("toggleterm").exec(cmd_to_run)
						end
						task:set_status("SUCCESS")
					end)
				end
			end)
		end

		vim.keymap.set("n", "<leader>br", function()
			run_task_by_name("run")
		end, { desc = "▶️ Run" })
		vim.keymap.set("n", "<leader>bb", function()
			run_task_by_name("build")
		end, { desc = "🔨 Build" })
		vim.keymap.set("n", "<leader>bt", function()
			run_task_by_name("test")
		end, { desc = "🧪 Test" })
		vim.keymap.set("n", "<leader>bc", function()
			run_task_by_name("clean")
		end, { desc = "🧹 Clean" })
		vim.keymap.set("n", "<leader>bd", function()
			run_task_by_name("deploy")
		end, { desc = "🚀 Deploy" })

		local function get_quick_run_defaults()
			local hardcoded = {
				cpp = "g++ -O3 -Wall {file} -o {bin} && {bin}",
				c = "gcc -O3 -Wall {file} -o {bin} && {bin}",
				py = "python3 {file}",
				sh = "bash {file}",
				js = "node {file}",
				go = "go run {file}",
				lua = "lua {file}",
				rs = "rustc {file} -o {bin} && {bin}",
			}
			if vim.fn.filereadable(global_config_path) == 1 then
				local ok, user_defaults = pcall(dofile, global_config_path)
				if ok and type(user_defaults) == "table" then
					return vim.tbl_deep_extend("force", hardcoded, user_defaults)
				end
			end
			return hardcoded
		end

		local function execute_quick_run(cmd, name)
			if cmd == "" then
				return
			end
			local task = overseer.new_task({
				name = "Quick Run: " .. name,
				cmd = "echo 'Launching terminal...'",
				metadata = { real_cmd = cmd },
				components = { "default" },
			})
			task:subscribe("on_start", function()
				require("toggleterm").exec(cmd)
				task:set_status("SUCCESS")
			end)
			task:start()
			vim.notify("🚀 Running: " .. name, vim.log.levels.INFO)
		end

		vim.keymap.set("n", "<leader>bx", function()
			local file = vim.api.nvim_buf_get_name(0)
			local root = vim.fn.fnamemodify(file, ":t:r")
			local ext = vim.fn.fnamemodify(file, ":e")
			local bin = "/tmp/nvim_build_" .. root
			local defaults = get_quick_run_defaults()
			local raw_cmd = defaults[ext] or ""
			local final_cmd = raw_cmd:gsub("{file}", "'" .. file .. "'"):gsub("{bin}", "'" .. bin .. "'")
			execute_quick_run(final_cmd, root)
		end, { desc = "🚀 Instant Run" })

		vim.keymap.set("n", "<leader>bX", function()
			local file = vim.api.nvim_buf_get_name(0)
			local root = vim.fn.fnamemodify(file, ":t:r")
			local ext = vim.fn.fnamemodify(file, ":e")
			local bin = "/tmp/nvim_build_" .. root
			local defaults = get_quick_run_defaults()
			local raw_cmd = defaults[ext] or ""
			local final_cmd = raw_cmd:gsub("{file}", "'" .. file .. "'"):gsub("{bin}", "'" .. bin .. "'")

			vim.ui.input({ prompt = "Configure Quick Run: ", default = final_cmd }, function(input)
				if not input or input == "" then
					return
				end
				execute_quick_run(input, root)
				if input ~= final_cmd then
					vim.defer_fn(function()
						vim.ui.input({ prompt = "Save as new project target?: " }, function(target_name)
							if not target_name or target_name == "" then
								return
							end
							local _, filename = get_toml_tasks()
							if not filename then
								filename = vim.fn.getcwd() .. "/overseer.toml"
							end
							local content = vim.fn.filereadable(filename) == 1 and vim.fn.readfile(filename) or {}
							local t_idx = 0
							for i, line in ipairs(content) do
								if line:match("^targets%s*=") then
									t_idx = i
									break
								end
							end
							if t_idx > 0 then
								content[t_idx] =
									content[t_idx]:gsub("(targets%s*=%s*%[.-)(%])", '%1, "' .. target_name .. '"%2')
							else
								table.insert(content, 1, 'targets = ["' .. target_name .. '"]')
							end
							table.insert(content, "")
							table.insert(content, "[" .. target_name .. ".run]")
							table.insert(content, 'cmd = "' .. input:gsub('"', '\\"') .. '"')
							vim.fn.writefile(content, filename)
							overseer.clear_task_cache()
						end)
					end, 500)
				end
			end)
		end, { desc = "⚙️ Config Run" })

		vim.keymap.set("n", "<leader>bP", function()
			vim.schedule(function()
				if #_G.BuildSystem.available_profiles == 0 then
					return
				end
				vim.ui.select(_G.BuildSystem.available_profiles, { prompt = "Select Profile:" }, function(choice)
					if choice then
						_G.BuildSystem.profile = choice
						save_state()
						vim.notify("Profile set to: " .. choice)
					end
				end)
			end)
		end, { desc = "🔀 Profile" })

		vim.keymap.set("n", "<leader>bT", function()
			vim.schedule(function()
				if #_G.BuildSystem.available_targets == 0 then
					return
				end
				vim.ui.select(_G.BuildSystem.available_targets, { prompt = "Select Target:" }, function(choice)
					if choice then
						_G.BuildSystem.target = choice
						save_state()
						overseer.clear_task_cache()
						vim.notify("Target switched to: " .. choice)
					end
				end)
			end)
		end, { desc = "🎯 Target" })

		local function get_clean_name(raw_name)
			local dot = raw_name:find("%.")
			return dot and raw_name:sub(dot + 1) or raw_name
		end

		vim.keymap.set("n", "<leader>be", function()
			vim.schedule(function()
				local tasks, _ = get_toml_tasks()
				local visible = {}
				for _, t in ipairs(tasks) do
					local dot = t.raw_name:find("%.")
					if not dot or t.raw_name:sub(1, dot - 1) == _G.BuildSystem.target then
						table.insert(visible, t)
					end
				end
				if #visible == 0 then
					return
				end
				vim.ui.select(visible, {
					prompt = "Edit Task (Session):",
					format_item = function(item)
						return get_clean_name(item.raw_name)
					end,
				}, function(choice)
					if not choice then
						return
					end
					local cur_p = _G.BuildSystem.profile
					local cur_v = (
						_G.BuildSystem.overrides[choice.raw_name] and _G.BuildSystem.overrides[choice.raw_name][cur_p]
					) or choice.cmd:gsub("{profile}", cur_p):gsub("{target}", _G.BuildSystem.target)
					vim.ui.input({ prompt = "Cmd: ", default = cur_v }, function(input)
						if input and input ~= "" then
							_G.BuildSystem.overrides[choice.raw_name] = _G.BuildSystem.overrides[choice.raw_name] or {}
							_G.BuildSystem.overrides[choice.raw_name][cur_p] = input
						end
					end)
				end)
			end)
		end, { desc = "✏️ Edit (Session)" })

		vim.keymap.set("n", "<leader>bE", function()
			vim.schedule(function()
				local tasks, filename = get_toml_tasks()
				if not filename then
					return
				end
				local visible = {}
				for _, t in ipairs(tasks) do
					local dot = t.raw_name:find("%.")
					if not dot or t.raw_name:sub(1, dot - 1) == _G.BuildSystem.target then
						table.insert(visible, t)
					end
				end
				if #visible == 0 then
					return
				end
				vim.ui.select(visible, {
					prompt = "Edit Task (DISK):",
					format_item = function(item)
						return get_clean_name(item.raw_name)
					end,
				}, function(choice)
					if not choice then
						return
					end
					vim.ui.input({ prompt = "Edit Template Cmd: ", default = choice.cmd }, function(input)
						if not input or input == "" or input == choice.cmd then
							return
						end
						local content = vim.fn.readfile(filename)
						local start_idx = 0
						local h1, h2 = "[" .. choice.raw_name .. "]", "[boring_" .. choice.raw_name .. "]"
						for i, line in ipairs(content) do
							if vim.trim(line) == h1 or vim.trim(line) == h2 then
								start_idx = i
								break
							end
						end
						if start_idx > 0 then
							for i = start_idx + 1, #content do
								if content[i]:match("^%[") then
									break
								end
								if content[i]:match("^cmd%s*=") then
									content[i] = string.format('cmd = "%s"', (input:gsub('"', '\\"')))
									vim.fn.writefile(content, filename)
									if _G.BuildSystem.overrides[choice.raw_name] then
										_G.BuildSystem.overrides[choice.raw_name] = nil
									end
									break
								end
							end
						end
					end)
				end)
			end)
		end, { desc = "💾 Edit (Disk)" })
	end,
}
