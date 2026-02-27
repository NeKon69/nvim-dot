return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"thehamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"igorlfs/nvim-dap-view",
			"stevearc/overseer.nvim",
			"Weissle/persistent-breakpoints.nvim",
		},
			config = function()
				local dap = require("dap")
				local project_root = require("user.project_root")
				local pb_utils = require("persistent-breakpoints.utils")
				local pb_cfg = require("persistent-breakpoints.config")
				dap.defaults.fallback.auto_continue_if_many_stopped = true
				local dap_debug_mode = (vim.g.dap_debug_mode == true) or (vim.env.NVIM_DAP_DEBUG == "1")
				local dap_log_file = vim.fn.stdpath("state") .. "/dap-launch.log"
				pcall(dap.set_log_level, dap_debug_mode and "TRACE" or "ERROR")

				local function safe_json(value)
					local ok, encoded = pcall(vim.json.encode, value)
					if ok and encoded then
						return encoded
					end
					return vim.inspect(value)
				end

				local function append_dap_log(event_name, payload)
					if not dap_debug_mode then
						return
					end
					local line = string.format(
						"[%s] %s %s",
						os.date("%Y-%m-%d %H:%M:%S"),
						event_name,
						safe_json(payload or {})
					)
					pcall(vim.fn.writefile, { line }, dap_log_file, "a")
				end

				local function summarize_spec(spec)
					if type(spec) ~= "table" then
						return spec
					end
					return {
						name = spec.name,
						type = spec.type,
						request = spec.request,
						program = spec.program,
						cwd = spec.cwd,
						pythonPath = type(spec.pythonPath) == "string" and spec.pythonPath or nil,
						args_count = type(spec.args) == "table" and #spec.args or nil,
					}
				end

				local function trim_trailing_slash(path)
					if not path or path == "" or path == "/" then
						return path
					end
					return path:gsub("/+$", "")
				end

				local function stable_breakpoints_path()
					local path_sep = pb_utils.get_path_sep()
					local root = project_root.resolve() or vim.fn.getcwd()
					local base_filename = trim_trailing_slash(vim.fn.fnamemodify(root, ":p"))
					if jit and jit.os == "Windows" then
						base_filename = base_filename:gsub(":", "_")
					end
					local cp_filename = base_filename:gsub(path_sep, "_") .. ".json"
					return pb_cfg.save_dir .. path_sep .. cp_filename
				end

				pb_utils.get_bps_path = stable_breakpoints_path
					require("persistent-breakpoints").setup({
						save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints",
						load_breakpoints_event = nil,
						always_reload = true,
					})
					local pb_api = require("persistent-breakpoints.api")
					local pb_inmemory = require("persistent-breakpoints.inmemory")
					local dap_breakpoints = require("dap.breakpoints")
				local function pb_toggle_breakpoint()
					pb_api.toggle_breakpoint()
				end
				local function pb_set_conditional_breakpoint()
					pb_api.set_conditional_breakpoint()
				end
					local function breakpoint_exists(bufnr, line)
						local bps = dap_breakpoints.get()[bufnr] or {}
						for _, bp in pairs(bps) do
							if tonumber(bp.line) == tonumber(line) then
								return true
							end
						end
						return false
					end
					local breakpoint_preload_state = {
						running = false,
						done = false,
						callbacks = {},
					}

					local function queue_breakpoint_callback(cb)
						if type(cb) == "function" then
							table.insert(breakpoint_preload_state.callbacks, cb)
						end
					end

					local function flush_breakpoint_callbacks()
						local callbacks = breakpoint_preload_state.callbacks
						breakpoint_preload_state.callbacks = {}
						for _, cb in ipairs(callbacks) do
							pcall(cb)
						end
					end

						local function set_buffer_breakpoints(bufnr, bps)
						local existing_by_line = {}
						for _, bp in pairs(dap_breakpoints.get()[bufnr] or {}) do
							local line = tonumber(bp.line)
							if line then
								existing_by_line[line] = true
							end
						end
						for _, bp in pairs(bps) do
							local line = tonumber(bp.line)
							if line and line > 0 and not existing_by_line[line] and not breakpoint_exists(bufnr, line) then
								dap_breakpoints.set({
									condition = bp.condition,
									log_message = bp.logMessage,
									hit_condition = bp.hitCondition,
								}, bufnr, line)
								existing_by_line[line] = true
							end
							end
						end

						local function with_preload_eventignore(fn)
							local ignore = {
								BufReadPre = true,
								BufReadPost = true,
								BufRead = true,
								BufEnter = true,
								BufWinEnter = true,
								WinEnter = true,
								FileType = true,
								Syntax = true,
								User = true,
								LspAttach = true,
								LspDetach = true,
							}
							for event in tostring(vim.o.eventignore or ""):gmatch("[^,]+") do
								if event ~= "" then
									ignore[event] = true
								end
							end
							local merged = {}
							for event, _ in pairs(ignore) do
								table.insert(merged, event)
							end
							table.sort(merged)
							local previous = vim.o.eventignore
							vim.o.eventignore = table.concat(merged, ",")
							local ok, err = pcall(fn)
							vim.o.eventignore = previous
							return ok, err
						end

						local function optimize_preloaded_buffer(bufnr)
							if not vim.api.nvim_buf_is_loaded(bufnr) then
								return
							end
							pcall(function()
								vim.bo[bufnr].buflisted = false
								vim.bo[bufnr].bufhidden = "hide"
								vim.bo[bufnr].swapfile = false
								vim.bo[bufnr].undofile = false
							end)
							if vim.treesitter and vim.treesitter.stop then
								pcall(vim.treesitter.stop, bufnr)
							end
							if vim.diagnostic and vim.diagnostic.disable then
								pcall(vim.diagnostic.disable, bufnr)
							end
							if vim.lsp and vim.lsp.get_clients and vim.lsp.buf_detach_client then
								for _, client in ipairs(vim.lsp.get_clients({ bufnr = bufnr })) do
									pcall(vim.lsp.buf_detach_client, bufnr, client.id)
								end
							end
						end

						local function load_buffer_for_breakpoints(bufnr)
							if vim.api.nvim_buf_is_loaded(bufnr) then
								return true, false
							end
							with_preload_eventignore(function()
								vim.fn.bufload(bufnr)
							end)
							if not vim.api.nvim_buf_is_loaded(bufnr) then
								return false, false
							end
							optimize_preloaded_buffer(bufnr)
							return true, true
						end

						local function unload_preloaded_buffer(bufnr, should_unload)
							if not should_unload then
								return
							end
							if vim.fn.bufwinid(bufnr) ~= -1 then
								return
							end
							pcall(vim.cmd, "silent! noautocmd keepalt keepjumps bunload " .. bufnr)
						end

						local function run_breakpoint_preload_async(cb)
						queue_breakpoint_callback(cb)
						if breakpoint_preload_state.done then
							flush_breakpoint_callbacks()
							return
						end
						if breakpoint_preload_state.running then
							return
						end

						breakpoint_preload_state.running = true
						pcall(pb_api.reload_breakpoints)

						local jobs = {}
						local fbps = pb_inmemory.bps or {}
						for file_name, bps in pairs(fbps) do
							if
								type(file_name) == "string"
								and file_name ~= ""
								and type(bps) == "table"
								and not vim.tbl_isempty(bps)
							then
								local abs_path = vim.fn.fnamemodify(file_name, ":p")
								if vim.fn.filereadable(abs_path) == 1 then
									table.insert(jobs, { path = abs_path, bps = bps })
								end
							end
						end

						local idx = 1
						local function finish()
							breakpoint_preload_state.running = false
							breakpoint_preload_state.done = true
							flush_breakpoint_callbacks()
						end

						local function step()
								local processed = 0
								while idx <= #jobs and processed < 1 do
									processed = processed + 1
									local job = jobs[idx]
									idx = idx + 1
									local bufnr = vim.fn.bufadd(job.path)
									if bufnr > 0 then
										local loaded, should_unload = load_buffer_for_breakpoints(bufnr)
										if loaded then
											set_buffer_breakpoints(bufnr, job.bps)
											unload_preloaded_buffer(bufnr, should_unload)
										end
									end
								end
							if idx <= #jobs then
								vim.defer_fn(step, 0)
								return
							end
							finish()
						end

						vim.schedule(step)
					end

					local function ensure_breakpoints_preloaded(cb)
						run_breakpoint_preload_async(cb)
					end

					vim.schedule(function()
						ensure_breakpoints_preloaded()
					end)
					local pb_group = vim.api.nvim_create_augroup("PersistentBreakpointsAllFiles", { clear = true })
					vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
						group = pb_group,
						callback = function()
							breakpoint_preload_state.done = false
							ensure_breakpoints_preloaded()
						end,
					})

				require("nvim-dap-virtual-text").setup({
					enabled = true,
				enabled_commands = true,
				highlight_changed_variables = true,
				highlight_new_as_changed = true,
			})

			require("mason-nvim-dap").setup({
				ensure_installed = { "codelldb" },
				handlers = {},
			})

			local function get_anti_asm_commands()
				return {
					"settings set target.process.thread.step-in-avoid-nodebug true",
					"settings set target.process.thread.step-out-avoid-nodebug true",
				}
			end

			local function pick_process_by_name()
				return coroutine.create(function(dap_run_co)
					local name = vim.fn.input("Process name: ")
					if not name or name == "" then
						coroutine.resume(dap_run_co, dap.ABORT)
						return
					end
					local pids_str = vim.fn.system("pgrep -f " .. vim.fn.shellescape(name))
					local pids = {}
					for pid in pids_str:gmatch("%d+") do
						table.insert(pids, pid)
					end
					if #pids == 0 then
						vim.notify("No process found with name: " .. name, vim.log.levels.WARN)
						coroutine.resume(dap_run_co, dap.ABORT)
					elseif #pids == 1 then
						coroutine.resume(dap_run_co, tonumber(pids[1]))
					else
						vim.ui.select(pids, { prompt = "Select PID for '" .. name .. "':" }, function(choice)
							coroutine.resume(dap_run_co, choice and tonumber(choice) or dap.ABORT)
						end)
					end
				end)
			end

				local function get_system_python()
					local py3 = vim.fn.exepath("python3")
					if py3 ~= "" then
						return py3
					end
					local py = vim.fn.exepath("python")
					if py ~= "" then
						return py
					end
					return "python3"
				end

				local function get_mason_debugpy_python()
					local adapter = vim.fn.exepath("debugpy-adapter")
					if adapter == "" then
						return nil
					end
					local pkg_dir = vim.fn.fnamemodify(adapter, ":p:h:h")
					local py = pkg_dir .. "/venv/bin/python"
					if vim.fn.executable(py) == 1 then
						return py
					end
					return nil
				end

				local function get_debugpy_adapter()
					local mason_py = get_mason_debugpy_python()
					if mason_py then
						append_dap_log("debugpy_adapter", {
							mode = "mason_venv_python_module",
							command = mason_py,
							args = { "-m", "debugpy.adapter" },
						})
						return mason_py, { "-m", "debugpy.adapter" }
					end

					local adapter = vim.fn.exepath("debugpy-adapter")
					if adapter ~= "" then
						append_dap_log("debugpy_adapter", { mode = "binary", command = adapter })
						return adapter, {}
					end

					local python = get_system_python()
					append_dap_log("debugpy_adapter", {
						mode = "system_python_module",
						command = python,
						args = { "-m", "debugpy.adapter" },
					})
					return python, { "-m", "debugpy.adapter" }
				end

				local function get_project_python()
					local local_python = vim.fn.getcwd() .. "/.nvim/venv/bin/python"
					if vim.fn.executable(local_python) == 1 then
						return local_python
					end
					local mason_py = get_mason_debugpy_python()
					if mason_py then
						return mason_py
					end
					return get_system_python()
				end

			dap.configurations.cpp = {
				{
					name = "Launch file",
					type = "codelldb",
					request = "launch",
					program = function()
						return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
					end,
					cwd = "${workspaceFolder}",
					preRunCommands = get_anti_asm_commands,
				},
				{
					name = "Attach by PID",
					type = "codelldb",
					request = "attach",
					pid = require("dap.utils").pick_process,
					preRunCommands = get_anti_asm_commands,
				},
				{
					name = "Attach by name",
					type = "codelldb",
					request = "attach",
					pid = pick_process_by_name,
					preRunCommands = get_anti_asm_commands,
				},
			}
			dap.configurations.c = dap.configurations.cpp
			dap.configurations.rust = dap.configurations.cpp

				local python_adapter_cmd, python_adapter_args = get_debugpy_adapter()
				append_dap_log("dap_python_adapter_configured", {
					command = python_adapter_cmd,
					args = python_adapter_args,
				})
				dap.adapters.python = {
				type = "executable",
				command = python_adapter_cmd,
				args = python_adapter_args,
			}
			dap.configurations.python = {
				{
					type = "python",
					request = "launch",
					name = "Python: Launch current file",
					program = "${file}",
					cwd = "${workspaceFolder}",
					pythonPath = get_project_python,
				},
				{
					type = "python",
					request = "launch",
					name = "Python: Launch with args",
					program = "${file}",
					args = function()
						return vim.split(vim.fn.input("Args: "), " ", { trimempty = true })
					end,
					cwd = "${workspaceFolder}",
					pythonPath = get_project_python,
				},
				{
					type = "python",
					request = "attach",
					name = "Python: Attach debugpy (localhost:5678)",
					connect = function()
						local port = tonumber(vim.fn.input("Port: ", "5678"))
						return { host = "127.0.0.1", port = port or 5678 }
					end,
					cwd = "${workspaceFolder}",
					pathMappings = {
						{
							localRoot = "${workspaceFolder}",
							remoteRoot = ".",
						},
					},
				},
			}

			vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
			vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
			vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
			vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "DiagnosticHint", linehl = "DebugLine" })

			local function focus_code_window()
				for _, win in ipairs(vim.api.nvim_list_wins()) do
					local buf = vim.api.nvim_win_get_buf(win)
					if
						vim.api.nvim_get_option_value("buftype", { buf = buf }) == ""
						and vim.bo[buf].filetype ~= "dap-repl"
					then
						vim.api.nvim_set_current_win(win)
						return
					end
				end
			end

			local function get_step_granularity()
				if vim.bo.filetype == "dap-disassembly" then
					return "instruction"
				else
					return "statement"
				end
			end

			local function smart_step_over()
				dap.step_over({ granularity = get_step_granularity() })
			end

			local function smart_step_into()
				dap.step_into({ granularity = get_step_granularity() })
			end

				local function smart_step_out()
					dap.step_out({ granularity = get_step_granularity() })
				end

				local build_dir_cache = {}
				local file_bounds_cache = {}
				local build_dir_cache_ttl_ms = 15000
				local file_bounds_cache_ttl_ms = 180000
				local scan_generation = 0
				local debug_preflight_in_progress = false
				local base_ignored_dirs = {
					[".git"] = true,
					[".nvim"] = true,
					[".cache"] = true,
				}
				local function mtime_to_seconds(mtime)
					if not mtime then
						return 0
					end
					return (mtime.sec or 0) + ((mtime.nsec or 0) / 1e9)
				end
				local function normalize_path(path)
					if not path or path == "" then
						return nil
					end
					local normalized = vim.fn.fnamemodify(path, ":p")
					if normalized ~= "/" then
						normalized = normalized:gsub("/+$", "")
					end
					return normalized
				end
				local function is_absolute_path(path)
					return path:sub(1, 1) == "/" or path:match("^[A-Za-z]:[\\/]")
				end
				local function path_starts_with(path, prefix)
					local npath = normalize_path(path)
					local nprefix = normalize_path(prefix)
					if not npath or not nprefix then
						return false
					end
					if npath == nprefix then
						return true
					end
					return npath:sub(1, #nprefix + 1) == (nprefix .. "/")
				end
				local function is_build_like_name(name)
					local lower = (name or ""):lower()
					return lower == "build"
						or lower == "target"
						or lower == "out"
						or lower == "dist"
						or lower:match("^cmake%-build") ~= nil
						or lower:match("^build[-_]") ~= nil
						or lower:find("build", 1, true) ~= nil
				end
				local function resolve_program_path(program, root)
					if not program or program == "" then
						return nil
					end
					if is_absolute_path(program) then
						return normalize_path(program)
					end
					return normalize_path(root .. "/" .. program)
				end
					local function is_git_repo(root)
						local git_dir = normalize_path(root .. "/.git")
						return git_dir and (vim.fn.isdirectory(git_dir) == 1 or vim.fn.filereadable(git_dir) == 1)
					end
				local function add_build_dir(set, dir)
					local normalized = normalize_path(dir)
					if normalized and vim.fn.isdirectory(normalized) == 1 then
						set[normalized] = true
					end
				end
				local function add_build_dirs_from_candidate(set, root, raw_path)
					local token = tostring(raw_path or ""):gsub("^['\"]", ""):gsub("['\"],?$", "")
					if token == "" or token:find("{", 1, true) then
						return
					end
					local abs = is_absolute_path(token) and token or (root .. "/" .. token)
					local current = normalize_path(vim.fn.fnamemodify(abs, ":h"))
					while current and current ~= root and path_starts_with(current, root) do
						local base = vim.fn.fnamemodify(current, ":t")
						if is_build_like_name(base) then
							add_build_dir(set, current)
						end
						local parent = normalize_path(vim.fn.fnamemodify(current, ":h"))
						if not parent or parent == current then
							break
						end
						current = parent
					end
				end
				local function collect_build_dirs_from_justfile(set, root)
					local justfile = vim.fs.find({ "justfile", ".justfile" }, { path = root, upward = false, type = "file" })[1]
					if not justfile then
						return
					end
					local ok, lines = pcall(vim.fn.readfile, justfile)
					if not ok or type(lines) ~= "table" then
						return
					end
					for _, line in ipairs(lines) do
						local cleaned = line:gsub("#.*$", "")
						for quoted in cleaned:gmatch("[\"']([^\"']+)[\"']") do
							add_build_dirs_from_candidate(set, root, quoted)
						end
						for token in cleaned:gmatch("[^%s]+") do
							if token:find("/", 1, true) then
								add_build_dirs_from_candidate(set, root, token)
							end
						end
					end
				end
				local function collect_build_dirs_from_binary(set, root, program_abs)
					add_build_dirs_from_candidate(set, root, program_abs)
					local bin_dir = normalize_path(vim.fn.fnamemodify(program_abs or "", ":h"))
					if bin_dir and path_starts_with(bin_dir, root) then
						add_build_dir(set, bin_dir)
						local parent = normalize_path(vim.fn.fnamemodify(bin_dir, ":h"))
						if parent and parent ~= root and path_starts_with(parent, root) then
							add_build_dir(set, parent)
						end
					end
					local fs = vim.uv.fs_scandir(root)
					if not fs then
						return
					end
					while true do
						local name, typ = vim.uv.fs_scandir_next(fs)
						if not name then
							break
						end
						if typ == "directory" and is_build_like_name(name) then
							add_build_dir(set, root .. "/" .. name)
						end
					end
				end
				local function get_cached_build_dirs(root, program_abs)
					local key = tostring(root) .. "|" .. tostring(program_abs or "")
					local now = vim.uv.now()
					local cached = build_dir_cache[key]
					if cached and (now - cached.ts) < build_dir_cache_ttl_ms then
						return cached.dirs
					end
					local set = {}
					collect_build_dirs_from_justfile(set, root)
					collect_build_dirs_from_binary(set, root, program_abs)
					local dirs = {}
					for dir, _ in pairs(set) do
						table.insert(dirs, dir)
					end
					table.sort(dirs, function(a, b)
						return #a > #b
					end)
					build_dir_cache[key] = { ts = now, dirs = dirs }
					return dirs
				end
				local function build_dirs_cache_key(root, build_dirs, language)
					return root .. "|" .. table.concat(build_dirs, "|") .. "|" .. tostring(language or "")
				end
				local function is_in_build_dir(path, build_dirs)
					for _, dir in ipairs(build_dirs) do
						if path_starts_with(path, dir) then
							return true
						end
					end
					return false
				end
				local function has_base_ignored_segment(path)
					for segment in tostring(path):gmatch("[^/]+") do
						if base_ignored_dirs[segment] then
							return true
						end
					end
					return false
				end
				local function is_relevant_source_file(path, language)
					local ext = (vim.fn.fnamemodify(path or "", ":e") or ""):lower()
					local lang = (language or ""):lower()
					if lang == "cpp" or lang == "c" then
						return ext == "c"
							or ext == "cc"
							or ext == "cpp"
							or ext == "cxx"
							or ext == "h"
							or ext == "hh"
							or ext == "hpp"
							or ext == "hxx"
							or ext == "ipp"
							or ext == "inl"
					end
					if lang == "rust" then
						return ext == "rs"
					end
					if lang == "go" then
						return ext == "go"
					end
					if lang == "python" then
						return ext == "py"
					end
					if lang == "lua" then
						return ext == "lua"
					end
					return true
				end
				local function collect_git_candidate_files_async(root, build_dirs, language, cb)
						vim.system({
							"git",
							"-C",
						root,
						"ls-files",
						"--cached",
						"--others",
						"--exclude-standard",
							"-z",
						}, { text = false }, function(result)
							vim.schedule(function()
								if result.code ~= 0 then
									cb(nil)
									return
								end
								local files = {}
								local out = result.stdout or ""
								local out_len = #out
								local pos = 1
								local function step()
									local processed = 0
									while pos <= out_len and processed < 250 do
										local nul = out:find("\0", pos, true)
										if not nul then
											pos = out_len + 1
											break
										end
										local rel = out:sub(pos, nul - 1)
										pos = nul + 1
										processed = processed + 1
										if rel ~= "" and not has_base_ignored_segment(rel) then
											local abs = normalize_path(root .. "/" .. rel)
											if abs and not is_in_build_dir(abs, build_dirs) and is_relevant_source_file(abs, language) then
												table.insert(files, abs)
											end
										end
									end
									if pos <= out_len then
										vim.defer_fn(step, 0)
										return
									end
									cb(files)
								end
								step()
							end)
						end)
					end
				local function collect_fallback_candidate_files_async(root, build_dirs, language, cb)
						local files = {}
						local queue = {}
						local function push_dir(dir)
							local fs = vim.uv.fs_scandir(dir)
							if fs then
								table.insert(queue, { dir = dir, fs = fs })
							end
						end
						push_dir(root)

						local function step()
							local processed = 0
							while #queue > 0 and processed < 300 do
								local node = queue[#queue]
								local name, typ = vim.uv.fs_scandir_next(node.fs)
								if not name then
									table.remove(queue)
								else
									processed = processed + 1
									local full_path = normalize_path(node.dir .. "/" .. name)
									if typ == "directory" then
										if full_path and not base_ignored_dirs[name] and not is_in_build_dir(full_path, build_dirs) then
											push_dir(full_path)
										end
									elseif typ == "file" then
										if full_path and not is_in_build_dir(full_path, build_dirs) and is_relevant_source_file(full_path, language) then
											table.insert(files, full_path)
										end
									end
								end
							end
							if #queue > 0 then
								vim.defer_fn(step, 0)
								return
							end
							cb(files)
						end
						step()
					end
				local function compute_file_time_bounds_chunked(files, done)
					local idx = 1
					local newest = nil
					local newest_path = nil
					local count = 0
						local function step()
								local max_idx = math.min(idx + 80, #files + 1)
							while idx < max_idx do
								local path = files[idx]
								idx = idx + 1
							local stat = vim.uv.fs_stat(path)
							if stat and stat.type == "file" then
								local mt = mtime_to_seconds(stat.mtime)
								count = count + 1
								if not newest or mt > newest then
									newest = mt
									newest_path = path
								end
							end
						end
						if idx <= #files then
							vim.defer_fn(step, 0)
							return
						end
						done({
							count = count,
							newest = newest,
							newest_path = newest_path,
						})
					end
					step()
				end
				local function file_time_bounds_async(root, build_dirs, language, cb)
					local cache_key = build_dirs_cache_key(root, build_dirs, language)
					local now = vim.uv.now()
					local cached = file_bounds_cache[cache_key]
					if cached and cached.gen == scan_generation and (now - cached.ts) < file_bounds_cache_ttl_ms then
						cb(cached.bounds)
						return
					end

					local function finalize(files)
						compute_file_time_bounds_chunked(files or {}, function(bounds)
							file_bounds_cache[cache_key] = {
								ts = vim.uv.now(),
								gen = scan_generation,
								bounds = bounds,
							}
							cb(bounds)
						end)
					end

						if not is_git_repo(root) then
							collect_fallback_candidate_files_async(root, build_dirs, language, finalize)
							return
						end

						collect_git_candidate_files_async(root, build_dirs, language, function(files)
							if files then
								finalize(files)
							else
								collect_fallback_candidate_files_async(root, build_dirs, language, finalize)
							end
						end)
					end
				local function needs_rebuild_for_debug_async(program, language, cb)
					append_dap_log("rebuild_check_start", {
						program = program,
						language = language,
						filetype = vim.bo.filetype,
						root = project_root.resolve() or vim.fn.getcwd(),
					})
					local root = normalize_path(project_root.resolve() or vim.fn.getcwd())
					if not root or vim.fn.isdirectory(root) == 0 then
						append_dap_log("rebuild_check_result", { should_build = true, reason = "invalid project root", program = program })
						cb(true, "invalid project root", program)
						return
					end
					local program_abs = resolve_program_path(program, root)
					if not program_abs then
						append_dap_log("rebuild_check_result", { should_build = true, reason = "missing debug program", program = program })
						cb(true, "missing debug program", program)
						return
					end
					local bin_stat = vim.uv.fs_stat(program_abs)
					if not bin_stat then
						append_dap_log("rebuild_check_result", { should_build = true, reason = "missing binary", program = program_abs })
						cb(true, "missing binary", program_abs)
						return
					end
					local build_dirs = get_cached_build_dirs(root, program_abs)
						file_time_bounds_async(root, build_dirs, language, function(bounds)
							if bounds.count == 0 then
								append_dap_log("rebuild_check_result", {
									should_build = true,
									reason = "no candidate files to compare",
									program = program_abs,
								})
								cb(true, "no candidate files to compare", program_abs)
								return
							end
							local bin_mtime = mtime_to_seconds(bin_stat.mtime)
							if bounds.newest and bounds.newest <= bin_mtime then
								append_dap_log("rebuild_check_result", {
									should_build = false,
									reason = "newest relevant file older/equal than binary",
									newest_path = bounds.newest_path,
									program = program_abs,
								})
								cb(false, "newest relevant file older/equal than binary: " .. (bounds.newest_path or "unknown"), program_abs)
								return
							end
							append_dap_log("rebuild_check_result", {
								should_build = true,
								reason = "newest relevant file newer than binary",
								newest_path = bounds.newest_path,
								program = program_abs,
							})
							cb(true, "newest relevant file newer than binary: " .. (bounds.newest_path or "unknown"), program_abs)
						end)
					end

				local DebugMode = { is_active = false, win_id = nil }
				local help_lines = {
				"  DEBUG MODE",
				"",
				" Step:         Stack:         Session:",
				" l: over       J: down        r: restart",
				" j: into       K: up          q: exit mode (bg)",
				" k: out                       b: breakpoint",
				" M: to code",
				"",
				" Misc:         UI (dap-view):",
				" c: continue   S: scopes      D: disassembly",
				" C: cursor     W: watches     R: REPL",
				"               B: breaks      T: threads",
				"               u: toggle UI",
			}
			local debug_map = {
				["l"] = { smart_step_over, "Step Over" },
				["j"] = { smart_step_into, "Step Into" },
				["k"] = { smart_step_out, "Step Out" },
				["J"] = { dap.down, "Stack Down" },
				["K"] = { dap.up, "Stack Up" },
					["c"] = { dap.continue, "Continue" },
					["C"] = { dap.run_to_cursor, "Run to Cursor" },
					["r"] = { dap.restart, "Restart" },
					["b"] = { pb_toggle_breakpoint, "Toggle Breakpoint" },
					["u"] = {
						function()
							require("dap-view").toggle()
					end,
					"Toggle UI",
				},
				["M"] = { focus_code_window, "Focus Code" },
				["S"] = {
					function()
						require("dap-view").jump_to_view("scopes")
					end,
					"Scopes",
				},
				["W"] = {
					function()
						require("dap-view").jump_to_view("watches")
					end,
					"Watches",
				},
				["B"] = {
					function()
						require("dap-view").jump_to_view("breakpoints")
					end,
					"Breakpoints",
				},
				["T"] = {
					function()
						require("dap-view").jump_to_view("threads")
					end,
					"Threads",
				},
				["R"] = {
					function()
						require("dap-view").jump_to_view("repl")
					end,
					"REPL",
				},
				["D"] = {
					function()
						require("dap-view").jump_to_view("disassembly")
					end,
					"Disassembly",
				},
				["q"] = {
					function()
						DebugMode.toggle(false)
					end,
					"Exit Mode (Keep Session)",
				},
				["<Esc>"] = {
					function()
						DebugMode.toggle(false)
					end,
					"Exit Mode",
				},
			}

			local function open_help_win()
				local buf = vim.api.nvim_create_buf(false, true)
				vim.api.nvim_buf_set_lines(buf, 0, -1, false, help_lines)
				local opts = {
					relative = "editor",
					width = 46,
					height = #help_lines,
					col = vim.o.columns - 46 - 2,
					row = vim.o.lines - #help_lines - 2,
					style = "minimal",
					border = "rounded",
					focusable = false,
				}
				DebugMode.win_id = vim.api.nvim_open_win(buf, false, opts)
			end

			function DebugMode.toggle(enable)
				if enable == nil then
					enable = not DebugMode.is_active
				end
				if enable then
					if DebugMode.is_active then
						return
					end
					DebugMode.is_active = true
					for key, val in pairs(debug_map) do
						vim.keymap.set("n", key, val[1], { desc = val[2] })
					end
					if DebugMode.win_id and vim.api.nvim_win_is_valid(DebugMode.win_id) then
						vim.api.nvim_win_close(DebugMode.win_id, true)
					end
					open_help_win()
					vim.notify("Debug Mode Enabled", vim.log.levels.INFO, { title = "DAP" })
				else
					if not DebugMode.is_active then
						return
					end
					DebugMode.is_active = false
					for key, _ in pairs(debug_map) do
						pcall(vim.keymap.del, "n", key)
					end
					if DebugMode.win_id and vim.api.nvim_win_is_valid(DebugMode.win_id) then
						vim.api.nvim_win_close(DebugMode.win_id, true)
						DebugMode.win_id = nil
					end
					vim.notify("Debug Mode Disabled", vim.log.levels.INFO, { title = "DAP" })
				end

				if package.loaded["lualine"] then
					require("lualine").refresh()
				end
			end

				local function disable_debug_mode_on_exit()
					append_dap_log("dap_mode_disable", { filetype = vim.bo.filetype })
					if DebugMode.is_active then
						DebugMode.toggle(false)
					end
				pcall(function()
					require("dap-view").close(true)
				end)
				pcall(vim.cmd, "stopinsert")
				focus_code_window()
			end

				dap.listeners.after.event_initialized["dap_mode_on"] = function()
					append_dap_log("dap_event_initialized", {
						filetype = vim.bo.filetype,
						buf = vim.api.nvim_buf_get_name(0),
					})
					DebugMode.toggle(true)
				end
				dap.listeners.after.event_terminated["dap_mode_off"] = function()
					append_dap_log("dap_event_terminated", {
						filetype = vim.bo.filetype,
						buf = vim.api.nvim_buf_get_name(0),
					})
					disable_debug_mode_on_exit()
				end
				dap.listeners.after.event_exited["dap_mode_off"] = function()
					append_dap_log("dap_event_exited", {
						filetype = vim.bo.filetype,
						buf = vim.api.nvim_buf_get_name(0),
					})
					disable_debug_mode_on_exit()
				end
			local cache_group = vim.api.nvim_create_augroup("DapBuildScanCache", { clear = true })
			vim.api.nvim_create_autocmd({ "BufWritePost", "DirChanged" }, {
				group = cache_group,
				callback = function()
					scan_generation = scan_generation + 1
				end,
			})
				local function terminate_debug_session()
					append_dap_log("terminate_requested", {
						has_session = dap.session() ~= nil,
						filetype = vim.bo.filetype,
					})
					if dap.session() then
						dap.terminate()
						vim.defer_fn(disable_debug_mode_on_exit, 50)
					return
				end
				disable_debug_mode_on_exit()
			end

				local function start_debug_session()
					local overseer = require("overseer")
					append_dap_log("debug_start_requested", {
						filetype = vim.bo.filetype,
						buf = vim.api.nvim_buf_get_name(0),
						cwd = vim.fn.getcwd(),
						root = project_root.resolve() or vim.fn.getcwd(),
					})
					local debug_spec, debug_err = _G.BuildSystem
						and _G.BuildSystem.get_current_debug_spec
						and _G.BuildSystem.get_current_debug_spec()
					append_dap_log("debug_spec_resolved", {
						ok = debug_spec ~= nil,
						error = debug_err,
						spec = summarize_spec(debug_spec),
					})
					if debug_spec then
						append_dap_log("debug_run_spec", summarize_spec(debug_spec))
						dap.run(debug_spec)
						return
					end
				local has_target_meta = _G.BuildSystem
					and _G.BuildSystem.has_current_target_debug_meta
					and _G.BuildSystem.has_current_target_debug_meta()
				local ft = vim.bo.filetype
				local is_native_fallback_ft = ft == "c" or ft == "cpp" or ft == "rust"
				if debug_err and (has_target_meta or not is_native_fallback_ft) then
					vim.notify(debug_err, vim.log.levels.WARN)
					return
				end
					local run_config = _G.BuildSystem
						and _G.BuildSystem.get_current_run_config
						and _G.BuildSystem.get_current_run_config()
					append_dap_log("run_config_resolved", {
						ok = run_config ~= nil,
						config = summarize_spec(run_config),
						filetype = vim.bo.filetype,
					})

							if run_config then
								local rc_lang = type(run_config.language) == "string" and run_config.language:lower() or nil
								local is_python_target = rc_lang == "python"
									or (vim.bo.filetype == "python")
									or (run_config.type == "python")
							if is_python_target then
								local root = project_root.resolve() or vim.fn.getcwd()
								local py = get_project_python()
								local launch_spec = {
									name = run_config.name or "Python: Launch (BuildSystem)",
									type = "python",
									request = "launch",
									program = resolve_program_path(run_config.program, root) or run_config.program,
									args = run_config.args,
									cwd = run_config.cwd or "${workspaceFolder}",
									pythonPath = py,
								}
								append_dap_log("launch_spec_built", {
									should_build = false,
									reason = "python adapter path",
									python = py,
									launch_spec = summarize_spec(launch_spec),
									run_config = summarize_spec(run_config),
									filetype = vim.bo.filetype,
								})
								append_dap_log("dap_run_launch_spec", summarize_spec(launch_spec))
								dap.run(launch_spec)
								return
							end
								if debug_preflight_in_progress then
									append_dap_log("debug_preflight_skip", { reason = "already running" })
									vim.notify("Debug preflight is already running...", vim.log.levels.INFO)
									return
								end
								debug_preflight_in_progress = true
								local rebuild_policy = (run_config.rebuild_policy or "auto"):lower()
								local build_task_name = run_config.build_task or "build"
								local function continue_with_decision(should_build, reason, program_path)
									vim.schedule(function()
										debug_preflight_in_progress = false
										local launch_spec = {
											name = "Overseer Debug",
											type = "codelldb",
											request = "launch",
											program = program_path or run_config.program,
											args = run_config.args,
											cwd = "${workspaceFolder}",
											preRunCommands = get_anti_asm_commands(),
										}
										append_dap_log("launch_spec_built", {
											should_build = should_build,
											reason = reason,
											launch_spec = summarize_spec(launch_spec),
											run_config = summarize_spec(run_config),
											filetype = vim.bo.filetype,
										})
										if not should_build then
											vim.notify("✅ Skipping build: " .. reason, vim.log.levels.INFO)
											append_dap_log("dap_run_launch_spec", summarize_spec(launch_spec))
											dap.run(launch_spec)
											return
										end
										vim.notify("🔨 Building before debug (" .. reason .. ")", vim.log.levels.INFO)
										append_dap_log("build_task_start", {
											task = build_task_name,
											profile = _G.BuildSystem and _G.BuildSystem.profile or nil,
										})
										overseer.run_task({
											name = build_task_name,
											params = { profile = _G.BuildSystem.profile },
										}, function(task)
											if not task then
												append_dap_log("build_task_missing", {})
												vim.notify("❌ Build task not found", vim.log.levels.ERROR)
												return
											end
											task:subscribe("on_complete", function(_, status)
												append_dap_log("build_task_complete", { status = status })
												if status == "SUCCESS" then
													vim.notify("✅ Build success, starting DAP", vim.log.levels.INFO)
													append_dap_log("dap_run_launch_spec", summarize_spec(launch_spec))
													dap.run(launch_spec)
												else
													vim.notify("❌ Build failed, debug aborted", vim.log.levels.ERROR)
												end
											end)
										end)
									end)
								end
								if rebuild_policy == "always" then
									continue_with_decision(true, "rebuild policy: always", run_config.program)
								elseif rebuild_policy == "never" then
									continue_with_decision(false, "rebuild policy: never", run_config.program)
								else
									needs_rebuild_for_debug_async(run_config.program, run_config.language, continue_with_decision)
								end
								return
							end
						append_dap_log("debug_start_aborted", {
							reason = debug_err or "No debug spec or run config available.",
							filetype = vim.bo.filetype,
						})
					vim.notify(debug_err or "No debug spec or run config available.", vim.log.levels.WARN)
					return
				end

				local function smart_dap_toggle()
					append_dap_log("smart_toggle_invoked", {
						has_session = dap.session() ~= nil,
						filetype = vim.bo.filetype,
					})
					if dap.session() then
						DebugMode.toggle()
						return
					end
					ensure_breakpoints_preloaded(start_debug_session)
				end

				local function debug_current_file()
					ensure_breakpoints_preloaded(function()
						append_dap_log("debug_current_file_requested", {
							filetype = vim.bo.filetype,
							buf = vim.api.nvim_buf_get_name(0),
						})
						if not _G.BuildSystem or not _G.BuildSystem.get_current_file_debug_spec then
							append_dap_log("debug_current_file_unavailable", { reason = "resolver missing" })
							vim.notify("BuildSystem debug resolver is unavailable.", vim.log.levels.WARN)
							return
						end
						local spec, err = _G.BuildSystem.get_current_file_debug_spec()
						if not spec then
							append_dap_log("debug_current_file_no_spec", { error = err })
							vim.notify(err or "No current-file debug spec.", vim.log.levels.WARN)
							return
						end
						append_dap_log("debug_current_file_run", summarize_spec(spec))
						dap.run(spec)
					end)
				end

				vim.keymap.set("n", "<leader>dd", smart_dap_toggle, { desc = "DAP: Smart Toggle/Start" })
				vim.keymap.set("n", "<leader>bD", debug_current_file, { desc = "Debug Current File" })

				vim.keymap.set("n", "<leader>dk", terminate_debug_session, { desc = "DAP: Terminate" })
				vim.keymap.set("n", "<leader>db", pb_toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
				vim.keymap.set("n", "<leader>do", function()
					require("dap-view").toggle()
				end, { desc = "DAP: Toggle UI" })
				vim.keymap.set("n", "<leader>dB", pb_set_conditional_breakpoint, { desc = "DAP: Conditional Breakpoint" })
			end,
		},
	{
		"igorlfs/nvim-dap-view",
		config = function()
			require("dap-view").setup({
				auto_toggle = true,
				winbar = {
					show = true,
					sections = { "watches", "scopes", "exceptions", "breakpoints", "threads", "repl", "disassembly" },
				},
			})
		end,
	},
	{
		"Jorenar/nvim-dap-disasm",
		url = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
		dependencies = { "mfussenegger/nvim-dap", "igorlfs/nvim-dap-view" },
		config = function()
			require("dap-disasm").setup({
				dapview_register = true,
			})
		end,
	},
}
