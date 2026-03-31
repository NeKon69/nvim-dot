return {
	{
		"kevinhwang91/nvim-ufo",
		lazy = false,
		dependencies = {
			"kevinhwang91/promise-async",
		},
		opts = function()
			return require("user.folding").ufo_opts()
		end,
		config = function(_, opts)
			require("ufo").setup(opts)
			require("user.folding").refresh_ufo_renderer()
		end,
	},
}
