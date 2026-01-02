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
		"echasnovski/mini.pairs",
		version = "*",
		event = "VeryLazy",
		opts = {
			modes = { insert = true, command = true, terminal = false },
		},
	},
}
