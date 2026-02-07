return {
	{
		"pwntester/octo.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-telescope/telescope.nvim",
			"nvim-tree/nvim-web-devicons",
		},
		event = "VeryLazy",
		cmd = "Octo",
		opts = {
			picker = "telescope",
			default_merge_method = "merge", -- можно поменять на squash или rebase
			default_delete_branch = false,
			enable_builtin = true,
			mappings_disable_default = false, -- оставляем стандартные, они хорошие
		},
		config = function(_, opts)
			require("octo").setup(opts)

			-- Регистрация Treesitter для корректной подсветки
			vim.treesitter.language.register("markdown", "octo")

			-- Автодополнение пользователей и тикетов
			vim.api.nvim_create_autocmd("FileType", {
				pattern = "octo",
				callback = function()
					vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })
					vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })
				end,
			})
		end,
		keys = {
			{ "<leader>gi", "<cmd>Octo issue list<cr>", desc = "List Issues" },
			{ "<leader>gr", "<cmd>Octo pr list<cr>", desc = "List PRs" },
			{ "<leader>gn", "<cmd>Octo notification list<cr>", desc = "List Notifications" },
			{ "<leader>gv", "<cmd>Octo repo view<cr>", desc = "View Current Repo" },
		},
	},
}
