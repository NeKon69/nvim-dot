return {
	"sudormrfbin/cheatsheet.nvim",
	lazy = false,
	dependencies = {
		"nvim-telescope/telescope.nvim",
		"nvim-lua/plenary.nvim",
		"nvim-lua/popup.nvim",
	},
	opts = {
		bundled_cheatsheets = {
			enabled = { "default", "regex", "nerd-fonts" },
		},

		bundled_plugin_cheatsheets = true,
		include_only_installed_plugins = true,
	},
	keys = {
		{ "<leader>??", "<cmd>Cheatsheet<cr>", desc = "Cheatsheet" },
		{ "<leader>?a", "<cmd>CheatsheetEdit<cr>", desc = "Add/Edit Cheatsheet" },
	},
}
