return {
	"ray-x/lsp_signature.nvim",
	event = "VeryLazy",
	opts = {
		bind = true,
		doc_lines = 0,
		floating_window_off_x = 1,
		floating_window_off_y = -1,
		padding = " ",
		hint_enable = false,
		handler_opts = {
			border = "rounded",
		},
	},
	config = function(_, opts)
		require("lsp_signature").setup(opts)
	end,
}
