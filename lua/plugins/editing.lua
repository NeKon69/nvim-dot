return {
	{
		"numToStr/Comment.nvim",
		opts = {
			ignore = "^%s*$",
		},
	},
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		opts = {
			highlight = {
				duration = 150,
			},
			aliases = {
				b = ")",
				B = "}",
				r = "]",
			},
		},
	},
	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		opts = {
			check_ts = true, -- Use treesitter to check for a pair
			disable_filetype = { "TelescopePrompt", "spectre_panel", "snacks_picker_input" },
		},
	},
}
