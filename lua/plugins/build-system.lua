_G.BuildSystem = _G.BuildSystem
	or {
		profile = "default",
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
		templates = { "builtin", "just" },
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
		opts.disable_template_modules = { "overseer.template.just" }
		overseer.setup(opts)

		local state_file = vim.fn.stdpath("state") .. "/build_system_just.json"

		-- === HELPERS ===

		local function get_just_info()
			local files = vim.fs.find({ "justfile", ".justfile" }, { upward = true, type = "file" })
			if #files == 0 then
				return nil, nil
			end
			local justfile = vim.fn.fnamemodify(files[1], ":p")
			local obj = vim.system({ "just", "--dump", "--dump-format", "json", "-f", justfile }, { text = true })
				:wait()
			if obj.code ~= 0 then
				return nil, justfile
			end
			local ok, decoded = pcall(vim.json.decode, obj.stdout)
			return ok and decoded or nil, justfile
		end

		local function save_state()
			local data = {}
			if vim.fn.filereadable(state_file) == 1 then
				local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(state_file))
				if ok then
					data = decoded
				end
			end
			data[vim.fn.getcwd()] = { profile = _G.BuildSystem.profile, target = _G.BuildSystem.target }
			vim.fn.writefile({ vim.fn.json_encode(data) }, state_file)
			pcall(function()
				require("lualine").refresh()
			end)
		end

		local function load_state()
			if vim.fn.filereadable(state_file) == 1 then
				local ok, decoded = pcall(vim.fn.json_decode, vim.fn.readfile(state_file))
				if ok and decoded[vim.fn.getcwd()] then
					local saved = decoded[vim.fn.getcwd()]
					_G.BuildSystem.profile = saved.profile or "default"
					_G.BuildSystem.target = saved.target or "Default"
				end
			end
		end

		local function evaluate_with_overrides(var_name, justfile, data)
			local args = {}
			if data.assignments.profile then
				table.insert(args, "profile=" .. _G.BuildSystem.profile)
			end
			if data.assignments.target then
				table.insert(args, "target=" .. _G.BuildSystem.target)
			end
			for k, v in pairs(_G.BuildSystem.overrides) do
				if data.assignments[k] then
					table.insert(args, string.format("%s=%s", k, v))
				end
			end
			local tmp = vim.fn.tempname() .. ".just"
			vim.fn.writefile(
				{ string.format("import '%s'", justfile), "_query:", "    @echo {{ " .. var_name .. " }}" },
				tmp
			)
			local cmd = { "just", "-f", tmp }
			vim.list_extend(cmd, args)
			table.insert(cmd, "_query")
			local obj = vim.system(cmd, { text = true }):wait()
			vim.fn.delete(tmp)
			return obj.code == 0 and vim.trim(obj.stdout) or nil
		end

		local function refresh_metadata()
			local data, _ = get_just_info()
			if data and data.assignments then
				if data.assignments.profiles then
					_G.BuildSystem.available_profiles = vim.split(data.assignments.profiles.value, " ")
					if
						(_G.BuildSystem.profile == "default" or _G.BuildSystem.profile == "normal")
						and #_G.BuildSystem.available_profiles > 0
					then
						_G.BuildSystem.profile = _G.BuildSystem.available_profiles[1]
					end
				end
				if data.assignments.targets then
					_G.BuildSystem.available_targets = vim.split(data.assignments.targets.value, " ")
					if _G.BuildSystem.target == "Default" and #_G.BuildSystem.available_targets > 0 then
						_G.BuildSystem.target = _G.BuildSystem.available_targets[1]
					end
				end
			end
			pcall(function()
				require("lualine").refresh()
			end)
		end

		-- === TEMPLATE GENERATOR ===

		overseer.register_template({
			name = "just",
			generator = function(opts, cb)
				local data, justfile = get_just_info()
				if not data then
					return cb({})
				end
				local res = {}
				local current_target = _G.BuildSystem.target

				for raw_name, recipe in pairs(data.recipes) do
					if not recipe.private then
						local task_name = raw_name
						local is_visible = false
						local sep_pos = raw_name:find("_")

						if sep_pos then
							if raw_name:sub(1, sep_pos - 1) == current_target then
								task_name = raw_name:sub(sep_pos + 1)
								is_visible = true
							end
						else
							is_visible = true
						end

						if is_visible then
							table.insert(res, {
								name = task_name,
								params = {
									profile = { type = "string", default = _G.BuildSystem.profile },
									target = { type = "string", default = current_target },
								},
								builder = function(params)
									local args = {}
									if data.assignments.profile then
										table.insert(args, "profile=" .. params.profile)
									end
									if data.assignments.target then
										table.insert(args, "target=" .. params.target)
									end
									for k, v in pairs(_G.BuildSystem.overrides) do
										if data.assignments[k] then
											table.insert(args, string.format("%s=%s", k, v))
										end
									end

									local is_interactive = (task_name == "run")
										or (type(recipe.doc) == "string" and recipe.doc:find("@interactive"))

									local final_cmd_list = { "just" }
									if is_interactive then
										table.insert(final_cmd_list, "--no-deps")
									end
									table.insert(final_cmd_list, "-f")
									table.insert(final_cmd_list, justfile)
									vim.list_extend(final_cmd_list, args)
									table.insert(final_cmd_list, raw_name)

									local final_cmd_str = table.concat(final_cmd_list, " ")

									local task_components = { "default" }
									if recipe.dependencies and #recipe.dependencies > 0 then
										local deps = {}
										for _, dep in ipairs(recipe.dependencies) do
											local d_name = dep.recipe
											local d_sep = d_name:find("_")
											if d_sep and d_name:sub(1, d_sep - 1) == current_target then
												d_name = d_name:sub(d_sep + 1)
											end
											table.insert(
												deps,
												{ d_name, profile = params.profile, target = params.target }
											)
										end
										table.insert(task_components, { "dependencies", tasks = deps })
									end

									return {
										cmd = is_interactive and "echo 'Launching terminal...'" or final_cmd_list,
										strategy = "jobstart",
										components = task_components,
										metadata = { real_cmd = final_cmd_str },
										name = string.format("%s [%s]", task_name, params.profile),
									}
								end,
							})
						end
					end
				end
				cb(res)
			end,
		})

		-- === EXECUTION ===

		local function run_task_by_name(name)
			overseer.run_task({
				name = name,
				params = { profile = _G.BuildSystem.profile, target = _G.BuildSystem.target },
			}, function(task)
				if not task then
					return
				end
				task:subscribe("on_start", function()
					local cmd = task.metadata.real_cmd
					if cmd and task.cmd == "echo 'Launching terminal...'" then
						require("toggleterm").exec(cmd)
						task:set_status("SUCCESS")
					end
				end)
			end)
		end

		_G.BuildSystem.get_current_run_config = function()
			local data, justfile = get_just_info()
			if not data then
				return nil
			end
			local bin = evaluate_with_overrides("dap_bin", justfile, data)
			local args = evaluate_with_overrides("dap_args", justfile, data) or ""
			if bin and bin ~= "" then
				return { program = bin, args = vim.split(args, " ", { trimempty = true }) }
			end
			return nil
		end

		-- === KEYMAPS ===

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

		vim.keymap.set("n", "<leader>bx", function()
			local file = vim.api.nvim_buf_get_name(0)
			local root = vim.fn.fnamemodify(file, ":t:r")
			local bin = "/tmp/nvim_build_" .. root
			local ext = vim.fn.fnamemodify(file, ":e")
			local map = { cpp = "g++ -O3", c = "gcc -O3", rs = "rustc", py = "python3", go = "go run" }
			local cmd = string.format("%s '%s' -o '%s' && '%s'", map[ext] or "bash", file, bin, bin)
			if ext == "py" or ext == "go" then
				cmd = string.format("%s '%s'", map[ext], file)
			end
			overseer.new_task({ name = "Quick: " .. root, cmd = cmd, components = { "default" } }):start()
		end)

		vim.keymap.set("n", "<leader>be", function()
			local data, _ = get_just_info()
			if not data or not data.assignments.dap_args then
				return
			end
			local prev = _G.BuildSystem.overrides["dap_args"] or data.assignments.dap_args.value
			vim.ui.input({ prompt = "Edit dap_args (Session): ", default = prev }, function(input)
				if input then
					_G.BuildSystem.overrides["dap_args"] = input
				end
			end)
		end)

		vim.keymap.set("n", "<leader>bE", function()
			local data, justfile = get_just_info()
			if not data then
				return
			end
			local current_target = _G.BuildSystem.target
			local choices = {}

			-- Собираем только подходящие рецепты
			for n, r in pairs(data.recipes) do
				if not r.private then
					local s = n:find("_")
					-- Добавляем если: глобальный (нет _) или совпадает таргет
					if not s or n:sub(1, s - 1) == current_target then
						table.insert(choices, n)
					end
				end
			end

			-- Сортируем для порядка
			table.sort(choices)

			vim.ui.select(choices, {
				prompt = "Jump to Recipe:",
				-- Показываем красивые короткие имена в меню
				format_item = function(item)
					local s = item:find("_")
					return s and item:sub(s + 1) or item
				end,
			}, function(full_name)
				if not full_name then
					return
				end
				-- Дальше логика остается прежней...
				local o = vim.system({ "just", "-f", justfile, "--show", full_name }, { text = true }):wait()
				if o.code ~= 0 then
					return
				end
				local show_lines = vim.split(o.stdout, "\n", { trimempty = true })
				vim.cmd("edit " .. justfile)
				local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
				for i, line in ipairs(lines) do
					if line:match("^" .. full_name .. "[:%s]") or line == full_name then
						local start_line = i
						for j, sl in ipairs(show_lines) do
							if sl:match("^" .. full_name .. "[:%s]") or sl == full_name then
								start_line = i - (j - 1)
								break
							end
						end
						vim.api.nvim_win_set_cursor(0, { math.max(1, start_line), 0 })
						vim.cmd("normal! zzV")
						if #show_lines > 1 then
							vim.cmd("normal! " .. (#show_lines - 1) .. "j")
						end
						break
					end
				end
			end)
		end, { desc = "💾 Edit Justfile" })

		vim.keymap.set("n", "<leader>bP", function()
			refresh_metadata()
			if #_G.BuildSystem.available_profiles == 0 then
				return
			end
			vim.ui.select(_G.BuildSystem.available_profiles, { prompt = "Profile:" }, function(c)
				if c then
					_G.BuildSystem.profile = c
					save_state()
					overseer.clear_task_cache()
				end
			end)
		end)

		vim.keymap.set("n", "<leader>bT", function()
			refresh_metadata()
			if #_G.BuildSystem.available_targets == 0 then
				return
			end
			vim.ui.select(_G.BuildSystem.available_targets, { prompt = "Target:" }, function(c)
				if c then
					_G.BuildSystem.target = c
					save_state()
					overseer.clear_task_cache()
				end
			end)
		end)

		local group = vim.api.nvim_create_augroup("BuildSystemJust", { clear = true })
		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			group = group,
			callback = function()
				load_state()
				refresh_metadata()
			end,
		})
		vim.api.nvim_create_autocmd("BufWritePost", {
			group = group,
			pattern = { "justfile", ".justfile" },
			callback = function()
				refresh_metadata()
				overseer.clear_task_cache()
			end,
		})
	end,
}
