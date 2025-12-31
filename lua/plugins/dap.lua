return {
	"mfussenegger/nvim-dap",
	dependencies = {
		{ "rcarriga/nvim-dap-ui", dependencies = { "nvim-neotest/nvim-nio" } },
		"theHamsta/nvim-dap-virtual-text",
		"jay-babu/mason-nvim-dap.nvim",
	},

	config = function()
		local dap = require("dap")
		local dapui = require("dapui")

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
			render = {
				max_value_lines = 100,
			},
		})

		require("nvim-dap-virtual-text").setup({
			enabled = true,
			enabled_commands = true,
			highlight_changed_variables = true,
			highlight_new_as_changed = true,
		})

		-- Конфигурация codelldb (лучше чем cpptools)
		dap.adapters.codelldb = {
			type = "server",
			port = "${port}",
			executable = {
				command = vim.fn.stdpath("data") .. "/mason/bin/codelldb",
				args = { "--port", "${port}" },
			},
		}

		-- Конфигурация для C/C++/Rust
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

		require("mason-nvim-dap").setup({
			ensure_installed = { "codelldb" },
			handlers = {},
		})

		-- Автоматическое открытие/закрытие UI
		dap.listeners.after.event_initialized["dapui_config"] = function()
			dapui.open()
		end
		dap.listeners.before.event_terminated["dapui_config"] = function()
			dapui.close()
		end
		dap.listeners.before.event_exited["dapui_config"] = function()
			dapui.close()
		end

		-- Знаки для брейкпоинтов
		vim.fn.sign_define("DapBreakpoint", { text = "🔴", texthl = "DiagnosticError" })
		vim.fn.sign_define("DapBreakpointCondition", { text = "🟡", texthl = "DiagnosticWarn" })
		vim.fn.sign_define("DapLogPoint", { text = "📝", texthl = "DiagnosticInfo" })
		vim.fn.sign_define("DapStopped", { text = "➡️", texthl = "DiagnosticHint", linehl = "DebugLine" })

		-- Основные кеймапы
		local map = vim.keymap.set
		map("n", "<F5>", dap.continue, { desc = "DAP: Continue" })
		map("n", "<S-F5>", dap.terminate, { desc = "DAP: Terminate" })
		map("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
		map("n", "<F10>", dap.step_over, { desc = "DAP: Step Over" })
		map("n", "<F11>", dap.step_into, { desc = "DAP: Step Into" })
		map("n", "<S-F11>", dap.step_out, { desc = "DAP: Step Out" })

		-- Расширенные брейкпоинты
		map("n", "<leader>db", dap.toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })
		map("n", "<leader>dB", function()
			dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
		end, { desc = "DAP: Conditional Breakpoint" })
		map("n", "<leader>lp", function()
			dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
		end, { desc = "DAP: Log Point" })

		map("n", "<leader>do", dapui.toggle, { desc = "DAP: Toggle UI" })
		map("n", "<leader>de", dapui.eval, { desc = "DAP: Evaluate" })
		map("v", "<leader>de", dapui.eval, { desc = "DAP: Evaluate selection" })
		map("n", "<leader>dr", function()
			dapui.float_element("repl", { enter = true })
		end, { desc = "DAP: REPL" })
	end,
}
