return {
	"andythigpen/nvim-coverage",
	dependencies = "nvim-lua/plenary.nvim",
	config = function()
		require("coverage").setup({
			auto_reload = true,
			lang = {
				cpp = {
					coverage_file = ".cov/coverage_final.info",
				},
			},
		})
	end,
}
