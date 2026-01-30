return {
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"thehamsta/nvim-dap-virtual-text",
			"jay-babu/mason-nvim-dap.nvim",
			"igorlfs/nvim-dap-view",
		},
		config = function()
			local dap = require("dap")
			dap.defaults.fallback.auto_continue_if_many_stopped = true

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
				["b"] = { dap.toggle_breakpoint, "Toggle Breakpoint" },
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
				if DebugMode.is_active then
					DebugMode.toggle(false)
				end
			end

			dap.listeners.after.event_initialized["dap_mode_on"] = function()
				DebugMode.toggle(true)
			end
			dap.listeners.after.event_terminated["dap_mode_off"] = disable_debug_mode_on_exit
			dap.listeners.after.event_exited["dap_mode_off"] = disable_debug_mode_on_exit

			local function smart_dap_toggle()
				if dap.session() then
					DebugMode.toggle()
				else
					dap.continue()
				end
			end

			vim.keymap.set("n", "<leader>dd", smart_dap_toggle, { desc = "DAP: Smart Toggle/Start" })

			vim.keymap.set("n", "<leader>dk", dap.terminate, { desc = "DAP: Terminate" })
			vim.keymap.set("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
			vim.keymap.set("n", "<leader>do", function()
				require("dap-view").toggle()
			end, { desc = "DAP: Toggle UI" })
			vim.keymap.set("n", "<leader>dB", function()
				dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
			end, { desc = "DAP: Conditional Breakpoint" })
		end,
	},
	{
		"igorlfs/nvim-dap-view",
		config = function()
			require("dap-view").setup({
				auto_toggle = true,
				windows = { terminal = { start_hidden = false } },
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
