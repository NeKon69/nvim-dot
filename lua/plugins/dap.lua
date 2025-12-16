-- lua/plugins/dap.lua
return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"theHamsta/nvim-dap-virtual-text",
		"jay-babu/mason-nvim-dap.nvim",
		"anuvyklack/hydra.nvim",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")
		local Hydra = require("hydra")

		-- [[ 1. Настройка DAP UI (твой конфиг) ]]
		dapui.setup({
			icons = { expanded = "▾", collapsed = "▸", current_frame = "▸" },
			floating = {
				max_height = 0.9,
				max_width = 0.9,
				border = "rounded",
				mappings = { close = { "q", "<Esc>" } },
			},
			layouts = {
				{
					elements = {
						{ id = "scopes", size = 0.4 },
						{ id = "breakpoints", size = 0.2 },
						{ id = "stacks", size = 0.2 },
						{ id = "watches", size = 0.2 },
					},
					position = "left",
					size = 40,
				},
				{
					elements = { { id = "repl", size = 0.5 }, { id = "console", size = 0.5 } },
					position = "bottom",
					size = 10,
				},
			},
			render = { max_value_lines = 100 },
		})

		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
		})

		-- [[ 2. Настройка адаптеров (твой конфиг) ]]
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = { command = vim.fn.stdpath("data") .. "/mason/bin/codelldb", args = { "--port", "${port}" } },
		}
		dap.configurations.cpp = {
			{
				name = "Launch file",
				type = "codelldb",
				request = "launch",
				program = function()
					return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
				end,
				cwd = "${workspaceFolder}",
				stopOnEntry = false,
				args = {},
			},
			{
				name = "Attach to process",
				type = "codelldb",
				request = "attach",
				pid = require("dap.utils").pick_process,
				args = {},
			},
		}
		dap.configurations.c = dap.configurations.cpp
		dap.configurations.rust = dap.configurations.cpp
		require("mason-nvim-dap").setup({ ensure_installed = { "codelldb" }, handlers = {} })

		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
		vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "DiagnosticHint", linehl = "DebugLine" })

		-- [[ 3. ФИНАЛЬНАЯ "Дебаг-Гидра" ]]
		local hint = [[
 ^ ^       󰃤 DEBUGGER 󰃤
 ^ ^ ────────────────────────
 _c_: 󰸐 Continue      _o_: 󰆚 Over
 _i_: 󰆹 Into          _u_: 󰆶 Out
 _b_: 󰄬 Breakpoint    _B_: 󰇘 Cond. Break.
 _r_: 󰅖 REPL          _k_: 󰓛 Terminate
 _q_: 󰅙 Quit
]]
		Hydra({
			name = "DAP Hydra",
			hint = hint,
			config = {
				invoke_on_body = true,
				foreign_keys = "run",
			},
			mode = "n",
			body = "<leader>sd",
			heads = {
				{ "c", dap.continue },
				{ "o", dap.step_over },
				{ "i", dap.step_into },
				{ "u", dap.step_out },
				{ "b", dap.toggle_breakpoint },
				{
					"B",
					function()
						dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
					end,
				},
				{
					"r",
					function()
						dapui.float_element("repl", { enter = true })
					end,
				},
				{ "k", dap.terminate },
				{ "q", nil, { exit = true } },
				{ "<Esc>", nil, { exit = true } },
			},
		})

		local map = vim.keymap.set
		map({ "n", "v" }, "<leader>de", dapui.eval, { desc = "DAP: Evaluate selection" })
		map("n", "<leader>do", dapui.toggle, { desc = "DAP: Toggle UI" })
		map("n", "<leader>lp", function()
			dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end, { desc = "DAP: Log Point" })
	end,
}
