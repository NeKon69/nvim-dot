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
			format_on_save = false,
		},
		config = function(_, opts)
			local conform = require("conform")
			conform.setup(opts)

			local group = vim.api.nvim_create_augroup("format_changed_hunks", { clear = true })
			vim.api.nvim_create_autocmd("BufWritePre", {
				group = group,
				callback = function(args)
					if vim.bo[args.buf].buftype ~= "" then
						return
					end

					local ok, gs = pcall(require, "gitsigns")
					if not ok then
						return
					end

					local hunks = gs.get_hunks(args.buf)
					if not hunks or vim.tbl_isempty(hunks) then
						return
					end

					table.sort(hunks, function(a, b)
						local a_start = (a.added and a.added.start) or 0
						local b_start = (b.added and b.added.start) or 0
						return a_start > b_start
					end)

					for _, hunk in ipairs(hunks) do
						local added = hunk.added
						if added and added.count and added.count > 0 then
							local start_line = added.start
							local end_line = start_line + added.count - 1
							conform.format({
								bufnr = args.buf,
								async = false,
								timeout_ms = 1000,
								lsp_fallback = true,
								range = {
									start = { start_line, 0 },
									["end"] = { end_line, 0 },
								},
							})
						end
					end
				end,
			})
		end,
	},
	{
		"mfussenegger/nvim-lint",
		event = { "BufReadPre", "BufNewFile" },
		config = function()
			local lint = require("lint")

			lint.linters_by_ft = {
				python = { "ruff" },
				json = { "jsonlint" },
				markdown = { "markdownlint" },
			}

			local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
			vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
				group = lint_augroup,

				callback = function()
					if vim.bo.buftype == "nofile" or vim.bo.filetype == "lspsagafinder" then
						return
					end
					lint.try_lint()
				end,
			})

			vim.keymap.set("n", "<leader>cl", function()
				lint.try_lint()
			end, { desc = "Trigger linting" })
		end,
	},
}
