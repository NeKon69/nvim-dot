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
		opts.disable_template_modules = { "overseer.template.just" }
		overseer.setup(opts)

		local state_file = vim.fn.stdpath("state") .. "/build_system_just.json"
		local debug_meta_name = ".nvim/debug_targets.json"

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

		local function evaluate_with_overrides(var_name, justfile, data)
			local justfile_abs = vim.fn.fnamemodify(justfile, ":p")
			local just_cwd = vim.fn.fnamemodify(justfile_abs, ":h")
			local args = {}
			if data.assignments.profile then
				table.insert(args, "profile=" .. _G.BuildSystem.profile)
			end
			if data.assignments.target then
				table.insert(args, "target=" .. _G.BuildSystem.target)
			end
			for k, v in pairs(_G.BuildSystem.overrides) do
				if data.assignments[k] then
					table.insert(args, string.format("%s='%s'", k, v))
				end
			end
			local tmp = string.format(
				"%s/.nvim_just_query_%d_%d.just",
				just_cwd,
				vim.fn.getpid(),
				math.floor(vim.loop.hrtime() / 1000)
			)
			vim.fn.writefile(
				{
					string.format("import '%s'", justfile_abs),
					"_query:",
					"    @echo {{ " .. var_name .. " }}",
				},
				tmp
			)
			local cmd = { "just", "-f", tmp }
			vim.list_extend(cmd, args)
			table.insert(cmd, "_query")
			local obj = vim.system(cmd, { text = true, cwd = just_cwd }):wait()
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
				return { program = bin, args = parse_args(args) }
			end
			return nil
		end
		_G.BuildSystem.get_current_debug_spec = get_current_debug_spec
		_G.BuildSystem.get_current_file_debug_spec = get_current_file_debug_spec
		_G.BuildSystem.set_target_debug_meta = set_target_debug_meta
		_G.BuildSystem.get_target_debug_meta = get_target_debug_meta
		_G.BuildSystem.has_current_target_debug_meta = has_current_target_debug_meta
		_G.BuildSystem.register_debug_resolver = register_debug_resolver

		vim.api.nvim_create_user_command("DebugTargetShow", function()
			local target = _G.BuildSystem.target or "Default"
			local entry = get_target_debug_meta(target, vim.fn.getcwd())
			if not entry then
				vim.notify("No debug metadata for target: " .. target, vim.log.levels.INFO)
				return
			end
			vim.notify("Debug target '" .. target .. "': " .. vim.inspect(entry), vim.log.levels.INFO)
		end, {})

		vim.api.nvim_create_user_command("DebugTargetEdit", function()
			local target = _G.BuildSystem.target or "Default"
			local cwd = vim.fn.getcwd()
			local existing = get_target_debug_meta(target, cwd) or {}
			local lang = prompt_with_default(
				string.format("debug language for target '%s': ", target),
				existing.language or "python"
			)
			if not lang then
				return
			end
			lang = lang:lower()
			existing.language = lang
			if lang == "python" then
				existing.mode = normalize_mode(
					prompt_with_default(
						string.format("debug mode for '%s' (launch/pytest): ", target),
						existing.mode or "launch"
					) or "launch"
				)
				if existing.mode == "pytest" then
					existing.pytest_target = prompt_with_default(
						string.format("pytest target for '%s': ", target),
						existing.pytest_target or "tests"
					) or existing.pytest_target
					existing.pytest_args = vim.fn.input(
						string.format("pytest args for '%s': ", target),
						existing.pytest_args or ""
					)
				else
					existing.program = prompt_with_default(
						string.format("program for '%s': ", target),
						existing.program
							or ((vim.fn.filereadable(cwd .. "/main.py") == 1 and "main.py") or "")
					) or existing.program
					existing.args = vim.fn.input(
						string.format("args for '%s': ", target),
						existing.args or ""
					)
				end
			end
			set_target_debug_meta(target, existing, cwd)
			vim.notify("Saved debug metadata for target: " .. target, vim.log.levels.INFO)
		end, {})

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
