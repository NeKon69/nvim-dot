-- lua/plugins/harpoon.lua
return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")
		harpoon:setup()

		harpoon:extend({
			UI_CREATE = function(cx)
				vim.keymap.set("n", "<M-j>", ":move .+1<CR>", {
					buffer = cx.bufnr,
					noremap = true,
					silent = true,
					desc = "Move Item Down",
				})

				vim.keymap.set("n", "<M-k>", ":move .-2<CR>", {
					buffer = cx.bufnr,
					noremap = true,
					silent = true,
					desc = "Move Item Up",
				})
			end,
		})
	end,
}
