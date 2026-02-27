_G.BuildSystem = _G.BuildSystem
	or {
		profile = "default",
		target = "Default",
		available_profiles = {},
		available_targets = {},
		overrides = {},
	}

-- Функция для парсинга аргументов с учетом кавычек
local function parse_args(args_str)
	local args = {}
	local current = ""
	local in_quote = nil
	local escaped = false

	for i = 1, #args_str do
		local char = args_str:sub(i, i)
		if escaped then
			current = current .. char
			escaped = false
		elseif char == "\\" then
			escaped = true
		elseif (char == '"' or char == "'") and not escaped then
			if in_quote == char then
				in_quote = nil
			elseif not in_quote then
				in_quote = char
			else
				current = current .. char
			end
		elseif char:match("%s") and not in_quote then
			if #current > 0 then
				table.insert(args, current)
				current = ""
			end
		else
			current = current .. char
		end
	end
	if #current > 0 then
		table.insert(args, current)
	end
	return args
end

local function read_json_file(path)
	if vim.fn.filereadable(path) ~= 1 then
		return {}
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or not lines or #lines == 0 then
		return {}
	end
	local decoded_ok, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not decoded_ok or type(decoded) ~= "table" then
		return {}
	end
	return decoded
end

local function write_json_file(path, data)
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, encoded = pcall(vim.json.encode, data)
	if not ok then
		return false
	end
	local tmp = path .. ".tmp"
	local wrote = pcall(vim.fn.writefile, { encoded }, tmp)
	if not wrote then
		return false
	end
	local renamed = os.rename(tmp, path)
	if not renamed then
		pcall(vim.fn.delete, tmp)
		return false
	end
	return true
end

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
		local targets_config = require("user.targets_config")
		local stable_project_root = require("user.project_root")
		opts.disable_template_modules = { "overseer.template.just" }
		overseer.setup(opts)
		targets_config.ensure_files()

		local state_file = vim.fn.stdpath("state") .. "/build_system_just.json"
		local debug_meta_name = ".nvim/debug_targets.json"
		local refresh_metadata
		local get_current_run_config_from_targets
		local run_program_probe

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
			local ok_t = targets_config.set_active_target(_G.BuildSystem.target)
			if ok_t then
				targets_config.set_active_profile(_G.BuildSystem.profile)
			end
			pcall(function()
				require("lualine").refresh()
			end)
		end

		local function load_runtime_state()
			local state = read_json_file(state_file)
			if type(state) ~= "table" then
				return {}
			end
			return state
		end

		local function save_runtime_state(state)
			if type(state) ~= "table" then
				return false
			end
			return write_json_file(state_file, state)
		end

		local function load_state()
			local target, profile = targets_config.get_active()
			if target then
				_G.BuildSystem.target = target
			end
			if profile then
				_G.BuildSystem.profile = profile
			end
		end

		local function get_python_interpreter(cwd)
			local project = cwd or vim.fn.getcwd()
			local venv_python = project .. "/.nvim/venv/bin/python"
			if vim.fn.executable(venv_python) == 1 then
				return venv_python
			end
			local py = vim.fn.exepath("python3")
			if py ~= "" then
				return py
			end
			return "python3"
		end

		local function get_project_root(cwd_hint)
			local start = cwd_hint or vim.fn.getcwd()
			local justfile = vim.fs.find({ "justfile", ".justfile" }, { upward = true, path = start, type = "file" })[1]
			if justfile then
				return vim.fn.fnamemodify(justfile, ":p:h")
			end
			local git = vim.fs.find({ ".git" }, { upward = true, path = start, type = "directory" })[1]
			if git then
				return vim.fn.fnamemodify(git, ":p:h")
			end
			return vim.fn.fnamemodify(start, ":p")
		end

		local function debug_meta_file(cwd)
			return get_project_root(cwd) .. "/" .. debug_meta_name
		end

		local function load_debug_meta(cwd)
			local data = read_json_file(debug_meta_file(cwd))
			data.targets = data.targets or {}
			return data
		end

		local function save_debug_meta(cwd, data)
			return write_json_file(debug_meta_file(cwd), data)
		end

		local function set_target_debug_meta(target, meta, cwd)
			local project = cwd or vim.fn.getcwd()
			local data = load_debug_meta(project)
			data.targets[target] = meta
			save_debug_meta(project, data)
		end

		local function get_target_debug_meta(target, cwd)
			local project = cwd or vim.fn.getcwd()
			local data = load_debug_meta(project)
			return data.targets[target]
		end

		local debug_resolvers = {}
		local function register_debug_resolver(language, resolver)
			debug_resolvers[language] = resolver
		end

		local function prompt_with_default(prompt, default_value)
			local value = vim.fn.input(prompt, default_value or "")
			if not value or value == "" then
				return nil
			end
			return value
		end

		local function normalize_mode(mode)
			local m = (mode or "launch"):lower()
			if m == "pytest" then
				return "pytest"
			end
			return "launch"
		end

		register_debug_resolver("python", function(target, meta, cwd)
			local entry = vim.deepcopy(meta or {})
			entry.language = "python"
			entry.mode = normalize_mode(entry.mode)

			if entry.mode == "launch" then
				if not entry.program or entry.program == "" then
					local default_program = vim.fn.filereadable(cwd .. "/main.py") == 1 and "main.py" or ""
					local program = prompt_with_default(
						string.format("debug target '%s' program: ", target),
						default_program
					)
					if not program then
						return nil, "Missing Python debug program."
					end
					entry.program = program
				end
				if entry.args == nil then
					local args = vim.fn.input(string.format("debug target '%s' args: ", target), "")
					entry.args = args or ""
				end
				return {
					{
						type = "python",
						request = "launch",
						name = "Target Debug: " .. target,
						program = entry.program,
						args = parse_args(entry.args or ""),
						cwd = cwd,
						pythonPath = get_python_interpreter(cwd),
					},
					entry,
				}
			end

			if not entry.pytest_target or entry.pytest_target == "" then
				local test_target = prompt_with_default(
					string.format("debug pytest target '%s': ", target),
					"tests"
				)
				if not test_target then
					return nil, "Missing pytest target."
				end
				entry.pytest_target = test_target
			end
			if entry.pytest_args == nil then
				local pytest_args = vim.fn.input(string.format("debug pytest args '%s': ", target), "")
				entry.pytest_args = pytest_args or ""
			end

			local args = { "-m", "pytest", entry.pytest_target }
			for _, v in ipairs(parse_args(entry.pytest_args or "")) do
				table.insert(args, v)
			end
			return {
				{
					type = "python",
					request = "launch",
					name = "Target Pytest Debug: " .. target,
					program = get_python_interpreter(cwd),
					args = args,
					cwd = cwd,
					pythonPath = get_python_interpreter(cwd),
				},
				entry,
			}
		end)

		local function detect_language_for_filetype(ft)
			local map = {
				python = "python",
				py = "python",
				c = "cpp",
				cpp = "cpp",
				rust = "rust",
				go = "go",
				lua = "lua",
			}
			return map[ft]
		end

		local function detect_language_for_target(target, cwd)
			local stored = get_target_debug_meta(target, cwd) or {}
			if stored.language then
				return stored.language, stored
			end

			local ft = vim.bo.filetype
			local guessed = detect_language_for_filetype(ft)
			if guessed then
				stored.language = guessed
				set_target_debug_meta(target, stored, cwd)
				return guessed, stored
			end

			local picked = prompt_with_default(
				string.format("debug language for target '%s' (python/cpp/rust/go/lua): ", target),
				"python"
			)
			if not picked then
				return nil, stored
			end
			stored.language = picked:lower()
			set_target_debug_meta(target, stored, cwd)
			return stored.language, stored
		end

		local function get_current_debug_spec()
			local cwd = vim.fn.getcwd()
			local target = _G.BuildSystem.target or "Default"
			local language, existing = detect_language_for_target(target, cwd)
			if not language then
				return nil, "No debug language selected."
			end
			local resolver = debug_resolvers[language]
			if not resolver then
				return nil, "No debug resolver for language: " .. language
			end

			local spec_and_entry, err = resolver(target, existing or {}, cwd)
			if not spec_and_entry then
				return nil, err
			end
			local spec, entry = spec_and_entry[1], spec_and_entry[2]
			entry.language = language
			set_target_debug_meta(target, entry, cwd)
			return spec
		end

		local function has_current_target_debug_meta()
			local cwd = vim.fn.getcwd()
			local target = _G.BuildSystem.target or "Default"
			return get_target_debug_meta(target, cwd) ~= nil
		end

		local function get_current_file_debug_spec()
			local file = vim.api.nvim_buf_get_name(0)
			if file == "" then
				return nil, "Current buffer has no file path."
			end
			local ft = vim.bo.filetype
			local language = detect_language_for_filetype(ft)
			if language ~= "python" then
				return nil, "Current-file debug is only configured for Python right now."
			end

			local cwd = vim.fn.fnamemodify(file, ":p:h")
			return {
				type = "python",
				request = "launch",
				name = "File Debug: " .. vim.fn.fnamemodify(file, ":t"),
				program = file,
				args = {},
				cwd = cwd,
				pythonPath = get_python_interpreter(vim.fn.getcwd()),
			}
		end

		run_program_probe = function(cmd_array)
			if type(cmd_array) ~= "table" or #cmd_array == 0 then
				return nil
			end
			local cmd = {}
			for _, v in ipairs(cmd_array) do
				table.insert(cmd, tostring(v))
			end
			local obj = vim.system(cmd, { text = true, cwd = vim.fn.getcwd() }):wait()
			if obj.code ~= 0 then
				return nil
			end
			return vim.trim(obj.stdout or "")
		end

		local function shell_join(parts)
			local out = {}
			for _, part in ipairs(parts or {}) do
				table.insert(out, vim.fn.shellescape(tostring(part)))
			end
			return table.concat(out, " ")
		end

		local function prompt_quote(arg)
			local s = tostring(arg or "")
			if s == "" then
				return '""'
			end
			if s:find("%s") or s:find('"') or s:find("'") then
				s = s:gsub("\\", "\\\\"):gsub('"', '\\"')
				return '"' .. s .. '"'
			end
			return s
		end

		local function prompt_join(parts)
			local out = {}
			for _, part in ipairs(parts or {}) do
				table.insert(out, prompt_quote(part))
			end
			return table.concat(out, " ")
		end

		local function list_equal(a, b)
			if type(a) ~= "table" or type(b) ~= "table" then
				return false
			end
			if #a ~= #b then
				return false
			end
			for i = 1, #a do
				if tostring(a[i]) ~= tostring(b[i]) then
					return false
				end
			end
			return true
		end

		local function build_template_command_for_active_run()
			local effective, err = targets_config.get_effective("run")
			if not effective then
				return nil, err
			end
			local parts = {}
			if type(effective.program) == "string" and effective.program ~= "" then
				table.insert(parts, effective.program)
			else
				local resolved_program = targets_config.resolve_program(effective, run_program_probe)
				if not resolved_program or resolved_program == "" then
					return nil, "No program resolved for run target '" .. effective.target .. "' profile '" .. effective.profile .. "'."
				end
				table.insert(parts, resolved_program)
			end
			if type(effective.args) == "table" then
				for _, a in ipairs(effective.args) do
					table.insert(parts, tostring(a))
				end
			else
				for _, a in ipairs(targets_config.resolve_args(effective)) do
					table.insert(parts, tostring(a))
				end
			end
			return prompt_join(parts), nil
		end

		local function sync_last_run_command_from_active()
			local cmd = build_template_command_for_active_run()
			if not cmd or cmd == "" then
				return
			end
			local s = load_runtime_state()
			s.last_run_command = cmd
			save_runtime_state(s)
		end

		local function rel_to_root(abs_path, root)
			local ap = vim.fn.fnamemodify(abs_path or "", ":p")
			local rp = vim.fn.fnamemodify(root or "", ":p")
			if rp ~= "/" then
				rp = rp:gsub("/+$", "")
			end
			if ap:sub(1, #rp + 1) == (rp .. "/") then
				return ap:sub(#rp + 2)
			end
			return ap
		end

		local function telescope_pick_file(cwd, prompt_title, cb)
			local ok, builtin = pcall(require, "telescope.builtin")
			if not ok then
				vim.notify("Telescope is not available", vim.log.levels.ERROR)
				cb(nil)
				return
			end
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			builtin.find_files({
				cwd = cwd,
				hidden = true,
				prompt_title = prompt_title,
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local rel = selection and (selection.path or selection.value or selection[1]) or nil
						if not rel then
							cb(nil)
							return
						end
						cb(vim.fn.fnamemodify(cwd .. "/" .. rel, ":p"))
					end)
					return true
				end,
			})
		end

		local function telescope_pick_dir(cwd, prompt_title, cb)
			local ok, builtin = pcall(require, "telescope.builtin")
			if not ok then
				vim.notify("Telescope is not available", vim.log.levels.ERROR)
				cb(nil)
				return
			end
			local actions = require("telescope.actions")
			local action_state = require("telescope.actions.state")
			local find_command
			if vim.fn.executable("fd") == 1 then
				find_command = { "fd", "--type", "d", "--hidden", "--exclude", ".git" }
			else
				find_command = { "find", ".", "-type", "d" }
			end
			builtin.find_files({
				cwd = cwd,
				prompt_title = prompt_title,
				find_command = find_command,
				attach_mappings = function(prompt_bufnr)
					actions.select_default:replace(function()
						local selection = action_state.get_selected_entry()
						actions.close(prompt_bufnr)
						local rel = selection and (selection.path or selection.value or selection[1]) or nil
						if not rel then
							cb(nil)
							return
						end
						rel = tostring(rel):gsub("^%./", "")
						cb(vim.fn.fnamemodify(cwd .. "/" .. rel, ":p"))
					end)
					return true
				end,
			})
		end

		local function target_wizard()
			refresh_metadata()
			local root = stable_project_root.resolve() or vim.fn.getcwd()
			local cfg = targets_config.load_config()
			local existing_targets = targets_config.list_targets()
			local target_choices = vim.deepcopy(existing_targets)
			table.insert(target_choices, "[+ New target]")
			vim.ui.select(target_choices, { prompt = "Target:" }, function(target_choice)
				if not target_choice then
					return
				end
				local function with_target(target_name)
					local profiles = targets_config.list_profiles(target_name)
					local profile_choices = vim.deepcopy(profiles)
					table.insert(profile_choices, "[+ New profile]")
					vim.ui.select(profile_choices, { prompt = "Profile:" }, function(profile_choice)
						if not profile_choice then
							return
						end
						local function with_profile(profile_name)
							local existing_target = cfg.targets[target_name] or {}
							local existing_profile = (existing_target.profiles or {})[profile_name] or {}
							local lang_default = existing_target.language or "cpp"
							vim.ui.select({ "cpp", "python" }, { prompt = "Language:", format_item = function(i)
								return i .. (i == lang_default and " (current)" or "")
							end }, function(language)
								if not language then
									return
								end
								vim.ui.select({ "shared", "profile" }, { prompt = "Store bin/args/cwd in:" }, function(scope)
									if not scope then
										return
									end
									local payload = {
										language = language,
										scope = scope,
										build_task = existing_target.build_task or "build",
										rebuild_policy = existing_target.rebuild_policy or "auto",
									}
									local function ask_program_mode(done)
										if language ~= "python" then
											done()
											return
										end
										local mode_default = existing_profile.mode or "launch"
										vim.ui.select({ "launch", "pytest" }, {
											prompt = "Python mode:",
											format_item = function(i)
												return i .. (i == mode_default and " (current)" or "")
											end,
										}, function(mode)
											if not mode then
												return
											end
											payload.mode = mode
											done()
										end)
									end
									local function ask_program(done)
										vim.ui.select({
											"Telescope file picker",
											"Manual path input",
											"Skip program",
										}, { prompt = "Program source:" }, function(choice)
											if not choice then
												return
											end
											if choice == "Skip program" then
												done()
												return
											end
											if choice == "Manual path input" then
												vim.ui.input({ prompt = "Program path: ", default = existing_profile.program or "" }, function(inp)
													if inp and inp ~= "" then
														payload.program = rel_to_root(vim.fn.expand(inp), root)
													end
													done()
												end)
												return
											end
											telescope_pick_file(root, "Select Program", function(abs_path)
												if abs_path then
													payload.program = rel_to_root(abs_path, root)
												end
												done()
											end)
										end)
									end
									local function ask_args(done)
										local args_default = table.concat(existing_profile.args or {}, " ")
										vim.ui.input({ prompt = "Args (space separated): ", default = args_default }, function(inp)
											payload.args = parse_args(inp or "")
											done()
										end)
									end
									local function ask_cwd(done)
										vim.ui.select({
											"Project root",
											"Telescope dir picker",
											"Manual dir input",
											"Skip cwd",
										}, { prompt = "CWD:" }, function(choice)
											if not choice then
												return
											end
											if choice == "Project root" then
												payload.cwd = root
												done()
												return
											end
											if choice == "Skip cwd" then
												done()
												return
											end
											if choice == "Manual dir input" then
												vim.ui.input({ prompt = "CWD path: ", default = existing_profile.cwd or root }, function(inp)
													if inp and inp ~= "" then
														payload.cwd = rel_to_root(vim.fn.expand(inp), root)
													end
													done()
												end)
												return
											end
											telescope_pick_dir(root, "Select CWD Directory", function(abs_path)
												if abs_path then
													payload.cwd = rel_to_root(abs_path, root)
												end
												done()
											end)
										end)
									end
									local function ask_policy(done)
										vim.ui.select({ "auto", "always", "never" }, { prompt = "Rebuild policy:" }, function(pol)
											if not pol then
												return
											end
											payload.rebuild_policy = pol
											vim.ui.input({
												prompt = "Build task name:",
												default = existing_target.build_task or "build",
											}, function(bt)
												payload.build_task = (bt and bt ~= "") and bt or "build"
												done()
											end)
										end)
									end
									local function ask_pytest(done)
										if language ~= "python" or payload.mode ~= "pytest" then
											done()
											return
										end
										vim.ui.input({
											prompt = "Pytest target:",
											default = existing_profile.pytest_target or "tests",
										}, function(test_target)
											payload.pytest_target = (test_target and test_target ~= "") and test_target or "tests"
											vim.ui.input({
												prompt = "Pytest args:",
												default = table.concat(existing_profile.pytest_args or {}, " "),
											}, function(pyargs)
												payload.pytest_args = parse_args(pyargs or "")
												done()
											end)
										end)
									end
									ask_program_mode(function()
										ask_program(function()
											ask_args(function()
												ask_cwd(function()
													ask_policy(function()
														ask_pytest(function()
															local ok_upsert, err_upsert = targets_config.upsert_target_profile(
																target_name,
																profile_name,
																payload
															)
															if not ok_upsert then
																vim.notify(err_upsert, vim.log.levels.ERROR)
																return
															end
															refresh_metadata()
															local active_target, active_profile = targets_config.get_active()
															if active_target then
																_G.BuildSystem.target = active_target
															end
															if active_profile then
																_G.BuildSystem.profile = active_profile
															end
															save_state()
															overseer.clear_task_cache()
															vim.notify(
																string.format("Updated target '%s' profile '%s'.", target_name, profile_name),
																vim.log.levels.INFO
															)
														end)
													end)
												end)
											end)
										end)
									end)
								end)
							end)
						end
						if profile_choice == "[+ New profile]" then
							vim.ui.input({ prompt = "New profile name: ", default = "default" }, function(inp_profile)
								if not inp_profile or inp_profile == "" then
									return
								end
								with_profile(inp_profile)
							end)
							return
						end
						with_profile(profile_choice)
					end)
				end
				if target_choice == "[+ New target]" then
					vim.ui.input({ prompt = "New target name: " }, function(inp_target)
						if not inp_target or inp_target == "" then
							return
						end
						with_target(inp_target)
					end)
					return
				end
				with_target(target_choice)
			end)
		end

		local function remove_profile_wizard()
			refresh_metadata()
			local target = _G.BuildSystem.target
			if not target or target == "" then
				vim.notify("No active target selected.", vim.log.levels.WARN)
				return
			end
			local profiles = targets_config.list_profiles(target)
			if #profiles == 0 then
				vim.notify("No profiles to remove for target: " .. target, vim.log.levels.WARN)
				return
			end
			vim.ui.select(profiles, { prompt = "Remove profile from " .. target .. ":" }, function(profile)
				if not profile then
					return
				end
				vim.ui.select({ "No", "Yes" }, {
					prompt = string.format("Delete profile '%s' from '%s'?", profile, target),
				}, function(confirm)
					if confirm ~= "Yes" then
						return
					end
					local ok, err = targets_config.delete_profile(target, profile)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
						return
					end
					refresh_metadata()
					local active_target, active_profile = targets_config.get_active()
					if active_target then
						_G.BuildSystem.target = active_target
					end
					if active_profile then
						_G.BuildSystem.profile = active_profile
					end
					save_state()
					overseer.clear_task_cache()
					vim.notify(string.format("Deleted profile '%s' from '%s'.", profile, target), vim.log.levels.INFO)
				end)
			end)
		end

		local function remove_target_wizard()
			refresh_metadata()
			local targets = targets_config.list_targets()
			if #targets == 0 then
				vim.notify("No targets to remove.", vim.log.levels.WARN)
				return
			end
			vim.ui.select(targets, { prompt = "Remove target:" }, function(target)
				if not target then
					return
				end
				vim.ui.select({ "No", "Yes" }, {
					prompt = string.format("Delete target '%s' (all profiles)?", target),
				}, function(confirm)
					if confirm ~= "Yes" then
						return
					end
					local ok, err = targets_config.delete_target(target)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
						return
					end
					refresh_metadata()
					local active_target, active_profile = targets_config.get_active()
					_G.BuildSystem.target = active_target or "Default"
					_G.BuildSystem.profile = active_profile or "default"
					save_state()
					overseer.clear_task_cache()
					vim.notify(string.format("Deleted target '%s'.", target), vim.log.levels.INFO)
				end)
			end)
		end

		refresh_metadata = function()
			local data, _ = get_just_info()
			local just_profiles = {}
			local just_targets = {}
			if data and data.assignments then
				if data.assignments.profiles then
					just_profiles = vim.split(data.assignments.profiles.value, " ", { trimempty = true })
				end
				if data.assignments.targets then
					just_targets = vim.split(data.assignments.targets.value, " ", { trimempty = true })
				end
			end
			targets_config.refresh_from_just(just_targets, just_profiles)
			_G.BuildSystem.available_targets = targets_config.list_targets()
			if #_G.BuildSystem.available_targets > 0 then
				local active_target, active_profile = targets_config.get_active()
				if not active_target or vim.tbl_contains(_G.BuildSystem.available_targets, active_target) == false then
					active_target = _G.BuildSystem.available_targets[1]
					targets_config.set_active_target(active_target)
				end
				_G.BuildSystem.target = active_target
				_G.BuildSystem.available_profiles = targets_config.list_profiles(active_target)
				if #_G.BuildSystem.available_profiles > 0 then
					if not active_profile or vim.tbl_contains(_G.BuildSystem.available_profiles, active_profile) == false then
						active_profile = _G.BuildSystem.available_profiles[1]
						targets_config.set_active_profile(active_profile)
					end
					_G.BuildSystem.profile = active_profile
				end
			else
				_G.BuildSystem.available_profiles = {}
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
										if k ~= "dap_args" and k ~= "dap_bin" and data.assignments[k] then
											table.insert(args, string.format("%s=%s", k, v))
										end
									end

									local is_interactive = (task_name == "run")
										or (type(recipe.doc) == "string" and recipe.doc:find("@interactive"))

									local final_cmd_list = { "just" }
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
										metadata = { real_cmd = final_cmd_str, interactive = is_interactive },
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
			if name == "run" then
				local effective, eff_err = targets_config.get_effective("run")
				if not effective then
					vim.notify(eff_err or "Run target is not configured.", vim.log.levels.ERROR)
					return
				end
				local run_cfg, run_err = get_current_run_config_from_targets()
				if not run_cfg then
					vim.notify(run_err or "Run target is not configured.", vim.log.levels.ERROR)
					return
				end
				local state = load_runtime_state()
				local cmd_template = state.last_run_command
				if type(cmd_template) ~= "string" or cmd_template == "" then
					cmd_template = build_template_command_for_active_run()
				end
				local rendered = targets_config.render_template(cmd_template or "", effective)
				local parts = parse_args(rendered)
				if #parts == 0 then
					vim.notify("Run command template is empty.", vim.log.levels.ERROR)
					return
				end
				local cmd = shell_join(parts)
				local function launch_run()
					require("toggleterm").exec(cmd, nil, nil, run_cfg.cwd or vim.fn.getcwd())
				end
				local build_task_name = run_cfg.build_task or "build"
				overseer.run_task({
					name = build_task_name,
					params = { profile = _G.BuildSystem.profile, target = _G.BuildSystem.target },
				}, function(task)
					if not task then
						vim.notify(("Build task '%s' not found, running anyway."):format(build_task_name), vim.log.levels.WARN)
						launch_run()
						return
					end
					task:subscribe("on_complete", function(_, status)
						if status == "SUCCESS" then
							launch_run()
						else
							vim.notify("Build failed, run aborted.", vim.log.levels.ERROR)
						end
					end)
				end)
				return
			end

			overseer.run_task({
				name = name,
				params = { profile = _G.BuildSystem.profile, target = _G.BuildSystem.target },
			}, function(task)
				if not task then
					vim.notify(("Task '%s' not found for target '%s'."):format(name, _G.BuildSystem.target), vim.log.levels.WARN)
					return
				end
				local function launch_interactive_task()
					if not task or not task.metadata or not task.metadata.interactive then
						return
					end
					if task.metadata._term_launched then
						return
					end
					local cmd = task.metadata.real_cmd
					if not cmd or cmd == "" then
						return
					end
					task.metadata._term_launched = true
					require("toggleterm").exec(cmd)
					task:set_status("SUCCESS")
				end
				launch_interactive_task()
				task:subscribe("on_start", function()
					launch_interactive_task()
				end)
			end)
		end

		local function open_args_console()
			local run_cfg, err = get_current_run_config_from_targets()
			if not run_cfg then
				vim.notify(err or "Run target is not configured.", vim.log.levels.ERROR)
				return
			end

			local state = load_runtime_state()
			local default_cmd
			local generated_default = build_template_command_for_active_run()
				or prompt_join(vim.list_extend({ run_cfg.program }, vim.deepcopy(run_cfg.args or {})))
			if type(state.last_run_command) == "string" and state.last_run_command ~= "" then
				local parsed = parse_args(state.last_run_command)
				if #parsed > 0 then
					default_cmd = state.last_run_command
				else
					default_cmd = generated_default
				end
			else
				default_cmd = generated_default
			end

			vim.cmd("tabnew")
			vim.cmd("enew")
			local prompt_win = vim.api.nvim_get_current_win()
			local prompt_buf = vim.api.nvim_get_current_buf()
			vim.api.nvim_buf_set_name(prompt_buf, "Build Runner Prompt")
			vim.bo[prompt_buf].buftype = "acwrite"
			vim.bo[prompt_buf].bufhidden = "wipe"
			vim.bo[prompt_buf].swapfile = false
			vim.bo[prompt_buf].filetype = "sh"
			vim.bo[prompt_buf].modifiable = true
			vim.api.nvim_buf_set_lines(prompt_buf, 0, -1, false, { default_cmd })

			local split_ok = pcall(vim.cmd, "belowright split")
			if not split_ok then
				vim.notify("Runner split failed: not enough room.", vim.log.levels.ERROR)
				return
			end
			local term_win = vim.api.nvim_get_current_win()
			local shell = vim.o.shell ~= "" and vim.o.shell or "sh"
			local term_buf
			local job_id = -1
			local function is_job_running()
				if not job_id or job_id <= 0 then
					return false
				end
				local ok, res = pcall(vim.fn.jobwait, { job_id }, 0)
				return ok and type(res) == "table" and res[1] == -1
			end
			local function attach_term_keymaps()
				vim.keymap.set("t", "<C-p>", function()
					vim.api.nvim_set_current_win(prompt_win)
					vim.cmd("startinsert!")
				end, { buffer = term_buf, silent = true, desc = "Focus runner prompt" })
				vim.keymap.set("n", "<CR>", function()
					if is_job_running() then
						vim.fn.chansend(job_id, "\n")
					end
				end, { buffer = term_buf, silent = true, desc = "Send Enter to runner terminal" })
			end
			local function ensure_terminal()
				if term_buf and vim.api.nvim_buf_is_valid(term_buf) and is_job_running() then
					return true
				end
				term_buf = vim.api.nvim_create_buf(false, true)
				vim.bo[term_buf].bufhidden = "wipe"
				vim.api.nvim_win_set_buf(term_win, term_buf)
				job_id = vim.fn.termopen({ shell, "-i" }, { cwd = run_cfg.cwd or vim.fn.getcwd() })
				if not job_id or job_id <= 0 then
					return false
				end
				attach_term_keymaps()
				return true
			end
			if not ensure_terminal() then
				vim.notify("Failed to start terminal job for runner console.", vim.log.levels.ERROR)
				return
			end
			pcall(vim.api.nvim_win_set_height, prompt_win, 3)

			local function persist_command(cmdline)
				local clean = (cmdline or ""):gsub("%s+$", "")
				local parts = parse_args(clean)
				local cfg = targets_config.load_config()
				local active_target, active_profile = targets_config.get_active()
				local target = active_target and cfg.targets and cfg.targets[active_target] or nil
				local profile = target and target.profiles and target.profiles[active_profile] or nil
				if type(profile) == "table" and #parts > 0 then
					local new_program = parts[1]
					local args = {}
					for i = 2, #parts do
						table.insert(args, parts[i])
					end
					local effective = targets_config.get_effective("run")
					local old_program = effective and effective.program or nil
					local old_args = (effective and type(effective.args) == "table") and effective.args or {}
					if old_program == nil or tostring(new_program) ~= tostring(old_program) then
						profile.program = new_program
					end
					if not list_equal(args, old_args or {}) then
						profile.args = args
					end
					targets_config.write_config(cfg)
				end
				local s = load_runtime_state()
				s.last_run_command = clean
				save_runtime_state(s)
				if vim.api.nvim_buf_is_valid(prompt_buf) then
					vim.bo[prompt_buf].modifiable = true
					vim.bo[prompt_buf].modified = false
				end
				return clean
			end

			local function current_command_line()
				if not vim.api.nvim_buf_is_valid(prompt_buf) then
					return ""
				end
				return vim.api.nvim_buf_get_lines(prompt_buf, 0, 1, false)[1] or ""
			end

			local function run_current_line()
				if not vim.api.nvim_buf_is_valid(prompt_buf) then
					return
				end
				vim.bo[prompt_buf].modifiable = true
				local cmdline = persist_command(current_command_line())
				if cmdline == "" then
					return
				end
				if not ensure_terminal() then
					vim.notify("Failed to ensure runner terminal.", vim.log.levels.ERROR)
					return
				end
				local effective = targets_config.get_effective("run")
				if effective then
					cmdline = targets_config.render_template(cmdline, effective)
				end
				vim.fn.chansend(job_id, "clear\n")
				vim.fn.chansend(job_id, cmdline .. "\n")
			end

			local group = vim.api.nvim_create_augroup("BuildRunnerConsole_" .. prompt_buf, { clear = true })
			vim.api.nvim_create_autocmd("BufWriteCmd", {
				group = group,
				buffer = prompt_buf,
				callback = function()
					persist_command(current_command_line())
					vim.cmd("tabclose!")
				end,
			})

			vim.keymap.set("n", "<CR>", run_current_line, {
				buffer = prompt_buf,
				silent = true,
				desc = "Run current command in runner terminal",
			})
			vim.keymap.set("i", "<CR>", function()
				run_current_line()
				return ""
			end, {
				buffer = prompt_buf,
				silent = true,
				expr = true,
				desc = "Run current command in runner terminal",
			})
			vim.keymap.set({ "n", "i" }, "<C-t>", function()
				vim.api.nvim_set_current_win(term_win)
				vim.cmd("startinsert")
			end, { buffer = prompt_buf, silent = true, desc = "Focus runner terminal" })
			vim.keymap.set("n", "q", function()
				vim.cmd("tabclose!")
			end, { buffer = prompt_buf, silent = true, desc = "Close runner tab" })

			vim.api.nvim_set_current_win(prompt_win)
			vim.api.nvim_win_set_cursor(prompt_win, { 1, math.max(0, #default_cmd) })
			vim.cmd("startinsert!")
		end

		get_current_run_config_from_targets = function()
			local effective, err = targets_config.get_effective("run")
			if not effective then
				return nil, err
			end
			local program = targets_config.resolve_program(effective, run_program_probe)
			local args = targets_config.resolve_args(effective)
			local cwd = targets_config.resolve_cwd(effective) or vim.fn.getcwd()
			if not program or program == "" then
				return nil, "No program resolved for run target '" .. effective.target .. "' profile '" .. effective.profile .. "'."
			end
			return {
				program = program,
				args = args,
				cwd = cwd,
				language = effective.language,
				rebuild_policy = effective.rebuild_policy or "auto",
				build_task = effective.build_task or "build",
			}
		end

		local function get_current_debug_spec_from_targets()
			local effective, err = targets_config.get_effective("debug")
			if not effective then
				return nil, err
			end
			if effective.language ~= "python" then
				return nil, nil
			end
			local mode = (effective.mode or "launch"):lower()
			local cwd = targets_config.resolve_cwd(effective) or vim.fn.getcwd()
			local python = get_python_interpreter(cwd)
			if mode == "pytest" then
				if not effective.pytest_target or effective.pytest_target == "" then
					return nil, "Missing required pytest_target for python debug profile."
				end
				local args = { "-m", "pytest", effective.pytest_target }
				for _, a in ipairs(effective.pytest_args or {}) do
					table.insert(args, a)
				end
				return {
					type = "python",
					request = "launch",
					name = string.format("Target Pytest Debug: %s[%s]", effective.target, effective.profile),
					program = python,
					args = args,
					cwd = cwd,
					pythonPath = python,
					env = effective.env or {},
				}
			end

			local program = targets_config.resolve_program(effective, run_program_probe)
			local args = targets_config.resolve_args(effective)
			if not program or program == "" then
				return nil, "No python program resolved for debug target '" .. effective.target .. "' profile '" .. effective.profile .. "'."
			end
			return {
				type = "python",
				request = "launch",
				name = string.format("Target Debug: %s[%s]", effective.target, effective.profile),
				program = program,
				args = args,
				cwd = cwd,
				pythonPath = python,
				env = effective.env or {},
			}
		end

		_G.BuildSystem.get_current_run_config = get_current_run_config_from_targets
		_G.BuildSystem.get_current_debug_spec = get_current_debug_spec_from_targets
		_G.BuildSystem.get_current_file_debug_spec = get_current_file_debug_spec
		_G.BuildSystem.set_target_debug_meta = set_target_debug_meta
		_G.BuildSystem.get_target_debug_meta = get_target_debug_meta
		_G.BuildSystem.has_current_target_debug_meta = function()
			local cfg = targets_config.load_config()
			local active_target, active_profile = targets_config.get_active()
			if not active_target or not active_profile then
				return false
			end
			local target = cfg.targets and cfg.targets[active_target]
			return type(target) == "table" and type(target.profiles) == "table" and target.profiles[active_profile] ~= nil
		end
		_G.BuildSystem.register_debug_resolver = register_debug_resolver

		vim.api.nvim_create_user_command("DebugTargetShow", function()
			local effective, err = targets_config.get_effective("debug")
			if not effective then
				vim.notify(err, vim.log.levels.WARN)
				return
			end
			vim.notify(
				string.format("Debug target '%s' profile '%s': %s", effective.target, effective.profile, vim.inspect(effective)),
				vim.log.levels.INFO
			)
		end, {})

		vim.api.nvim_create_user_command("DebugTargetEdit", function()
			local root = require("user.project_root").resolve() or vim.fn.getcwd()
			local path = root .. "/.nvim/targets.json"
			vim.cmd("edit " .. vim.fn.fnameescape(path))
		end, {})
		vim.api.nvim_create_user_command("TargetWizard", target_wizard, {})
		vim.api.nvim_create_user_command("TargetRemove", remove_target_wizard, {})
		vim.api.nvim_create_user_command("ProfileRemove", remove_profile_wizard, {})

		-- === QUICK RUN (Interactive + CWD fix) ===

		local function quick_run_interactive()
			local file = vim.api.nvim_buf_get_name(0)
			-- Получаем директорию файла
			local dir = vim.fn.fnamemodify(file, ":p:h")

			local root = vim.fn.fnamemodify(file, ":t:r")
			local bin = "/tmp/nvim_build_" .. root
			local ext = vim.fn.fnamemodify(file, ":e")
			local map = { cpp = "g++ -O3", c = "gcc -O3", rs = "rustc", py = "python3", go = "go run" }

			local cmd_str = ""

			if ext == "py" or ext == "go" then
				cmd_str = string.format("%s '%s'", map[ext], file)
			else
				local compiler = map[ext]
				if not compiler then
					cmd_str = string.format("bash '%s'", file)
				else
					cmd_str = string.format("%s '%s' -o '%s' && '%s'", compiler, file, bin, bin)
				end
			end

			local task = overseer.new_task({
				name = "Quick: " .. root,
				cmd = "echo 'Launching terminal...'",
				metadata = { real_cmd = cmd_str },
				components = { "default" },
			})

			task:subscribe("on_start", function(t)
				-- 4-й аргумент в exec - это директория (cwd)
				require("toggleterm").exec(t.metadata.real_cmd, nil, nil, dir)
				t:set_status("SUCCESS")
			end)

			task:start()
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

		vim.keymap.set("n", "<leader>bx", quick_run_interactive, { desc = "🚀 Quick Run (Term)" })
		vim.keymap.set("n", "<leader>bX", quick_run_interactive, { desc = "🚀 Quick Run (Term)" })
		vim.keymap.set("n", "<leader>ba", target_wizard, { desc = "🎯 Target Wizard" })
		vim.keymap.set("n", "<leader>bR", remove_target_wizard, { desc = "🗑️ Remove Target" })
		vim.keymap.set("n", "<leader>bp", remove_profile_wizard, { desc = "🗑️ Remove Profile" })

		vim.keymap.set("n", "<leader>be", open_args_console, { desc = "Args Console (Run on Enter)" })

		vim.keymap.set("n", "<leader>bE", function()
			local data, justfile = get_just_info()
			if not data then
				return
			end
			local current_target = _G.BuildSystem.target
			local choices = {}
			for n, r in pairs(data.recipes) do
				if not r.private then
					local s = n:find("_")
					if not s or n:sub(1, s - 1) == current_target then
						table.insert(choices, n)
					end
				end
			end
			table.sort(choices)
			vim.ui.select(choices, {
				prompt = "Jump to Recipe:",
				format_item = function(item)
					local s = item:find("_")
					return s and item:sub(s + 1) or item
				end,
			}, function(full_name)
				if not full_name then
					return
				end
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
					local ok, err = targets_config.set_active_profile(c)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
						return
					end
					_G.BuildSystem.profile = c
					save_state()
					sync_last_run_command_from_active()
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
					local ok, err = targets_config.set_active_target(c)
					if not ok then
						vim.notify(err, vim.log.levels.ERROR)
						return
					end
					_G.BuildSystem.target = c
					local _, active_profile = targets_config.get_active()
					if active_profile then
						_G.BuildSystem.profile = active_profile
					end
					save_state()
					_G.BuildSystem.available_profiles = targets_config.list_profiles(c)
					sync_last_run_command_from_active()
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
				sync_last_run_command_from_active()
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
