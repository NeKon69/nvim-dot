return {
	{
		"stevearc/conform.nvim",
		event = { "BufWritePre", "BufWritePost" },
		cmd = { "ConformInfo" },
		keys = {
			{
				"<leader>cf",
				function()
					require("conform").format({ async = true, lsp_fallback = true })
				end,
				mode = "",
				desc = "Format buffer",
			},
		},
		opts = {
			formatters_by_ft = {
				lua = { "stylua" },
				cpp = { "clang-format" },
				c = { "clang-format" },
				cuda = { "clang-format" },
				python = { "black" },
				rust = { "rustfmt" },
				json = { "jq" },
			},
			format_on_save = {
				timeout_ms = 1000,
				lsp_fallback = true,
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				lua = { "selene" },
				python = { "ruff" },
				json = { "jsonlint" },
				markdown = { "markdownlint" },
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
