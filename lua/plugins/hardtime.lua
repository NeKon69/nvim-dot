return {
	{
		"m4xshen/hardtime.nvim",
		dependencies = { "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim" },
		event = "VeryLazy",
		opts = {
			disable_mouse = false,
			max_count = 5,
			restriction_mode = "block",
			disabled_keys = {
				["<Up>"] = { "n", "i", "v", "o" },
				["<Down>"] = { "n", "i", "v", "o" },
				["<Left>"] = { "n", "i", "v", "o" },
				["<Right>"] = { "n", "i", "v", "o" },
			},
			restricted_keys = {
				["h"] = { "n", "x" },
				["j"] = { "n", "x" },
				["k"] = { "n", "x" },
				["l"] = { "n", "x" },
				["-"] = { "n", "x" },
				["+"] = { "n", "x" },
				["<CR>"] = { "n", "x" },
				["w"] = { "n", "x" },
				["b"] = { "n", "x" },
				["e"] = { "n", "x" },
			},
		},
	},
}
