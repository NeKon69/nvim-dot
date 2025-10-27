return {
	"folke/persistence.nvim",
	event = "VimEnter",
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		need = 0,
		branch = false,
	},
	init = function()
		vim.api.nvim_create_autocmd("VimEnter", {
			group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
			callback = function()
				require("persistence").load()
			end,
			nested = true,
		})
	end,
}
