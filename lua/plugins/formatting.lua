return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre" },
		cmd = { "ConformInfo" },
		keys = {
			{
				-- Хоткей для ручного форматирования: Leader + c + f
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			-- Какие форматтеры для каких языков
			formatters_by_ft = {
				lua = { "stylua" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				cuda = { "clang-format" },
				python = { "black" },
				rust = { "rustfmt" },
				json = { "jq" },
				-- asm = { "asmfmt" }, -- Раскомментируй, если asmfmt установлен
			},

			-- === ГЛАВНАЯ МАГИЯ (Format on Save) ===
			format_on_save = {
				timeout_ms = 1000, -- Если тупит дольше 1 сек — не ждать
				lsp_fallback = true, -- Если нет форматтера, попробовать через LSP (clangd)
				async = false, -- false = ждать окончания форматирования перед записью (чтобы файл не скакал)
			},
		},
		init = function()
			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					vim.g.is_exiting = true
				end,
			})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			-- Я убрал отсюда cmakelint, чтобы не спамило ошибками,
			-- раз ты решил отказаться от cmake.
			lint.linters_by_ft = {
				-- python = { "pylint" }, -- Пример, если нужен линтер для питона
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,
				callback = function()
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>cl", function()
				lint.try_lint()
			end, { desc = "Trigger linting" })
		end,
	},
}
