return {
	{
		"akinsho/toggleterm.nvim",
		version = "*",
		keys = {
			{
				[[<C-\>]],
				"<cmd>ToggleTerm direction=float<cr>",
				mode = { "n", "i" },
				desc = "💻 Toggle Floating Terminal",
			},
		},
		event = "VeryLazy",
		opts = {
			hide_numbers = true,
			shade_terminals = true,
			start_in_insert = true,
			persist_size = true,
			direction = "float",
			close_on_exit = true,
			shell = vim.o.shell,
			float_opts = {
				border = "rounded",
				winblend = 0,
				width = function()
					return math.ceil(vim.o.columns * 0.9)
				end,
				height = function()
					return math.ceil(vim.o.lines * 0.9)
				end,
			},
			on_open = function(term)
				vim.keymap.set("t", "<C-\\>", "<cmd>ToggleTerm<cr>", {
					buffer = term.bufnr,
					desc = "💻 Toggle Floating Terminal",
				})
			end,
		},
	},
}
