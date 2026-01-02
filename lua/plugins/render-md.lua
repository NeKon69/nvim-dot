return {
	"MeanderingProgrammer/render-markdown.nvim",
	dependencies = { "nvim-treesitter/nvim-treesitter", "nvim-tree/nvim-web-devicons" },
	opts = {
		enabled = true,
		render_modes = { "n", "c", "t", "v", "i", "V", "s", "S" },
		heading = {
			sign = true,
			icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
		},
		code = {
			sign = true,
			width = "block",
			right_pad = 1,
		},
		checkbox = {
			enabled = true,
		},
		bullet = {
			enabled = true,
			icons = { "●", "○", "◆", "◇" },
		},
		win_options = {
			conceallevel = {
				default = vim.o.conceallevel,
				rendered = 3,
			},
			concealcursor = {
				default = vim.o.concealcursor,
				rendered = "nvic",
			},
		},
		html = {
			enabled = true,
			comment = {
				conceal = true,
			},
		},
	},
}
