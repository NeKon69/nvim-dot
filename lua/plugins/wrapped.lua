return {
	{
		"aikhe/wrapped.nvim",
		event = "VimEnter",
		dependencies = { "nvzone/volt" },
		cmd = { "WrappedNvim" },
		opts = {},
		keys = {
			{ "<leader>tw", "<cmd>WrappedNvim<cr>", desc = "Wrapped Nvim" },
		},
	},
}
