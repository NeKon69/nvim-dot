return {
	{
		"olimorris/codecompanion.nvim",
		cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionActions" },
		keys = {
			{ "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", desc = "CodeCompanion Chat" },
			{ "<leader>aa", "<cmd>CodeCompanionActions<cr>", desc = "CodeCompanion Actions" },
		},
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		opts = function()
			local codex_command = { "codex-acp" }
			if vim.fn.executable("codex-acp") == 0 then
				codex_command = { "npx", "-y", "@zed-industries/codex-acp" }
			end

			return {
				adapters = {
					acp = {
						codex = function()
							return require("codecompanion.adapters").extend("codex", {
								commands = {
									default = codex_command,
								},
								defaults = {
									auth_method = "chatgpt",
								},
							})
						end,
					},
				},
				interactions = {
					chat = {
						adapter = "codex",
					},
				},
				display = {
					chat = {
						window = {
							layout = "float",
							width = 0.9,
							height = 0.9,
							border = "rounded",
							relative = "editor",
						},
					},
				},
			}
		end,
	},
}
