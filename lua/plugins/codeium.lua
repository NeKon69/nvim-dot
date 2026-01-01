return {
	"Exafunction/windsurf.nvim",
	event = "InsertEnter",
	dependencies = {
		"nvim-lua/plenary.nvim",
		"hrsh7th/nvim-cmp",
	},
	config = function()
		require("codeium").setup({
			enable_cmp_source = true,
			enable_chat = true,
			virtual_text = {
				enabled = true,
			},
		})

		vim.api.nvim_set_hl(0, "CodeiumSuggestion", { link = "Comment" })

		require("codeium.virtual_text").set_statusbar_refresh(function()
			local status, lualine = pcall(require, "lualine")
			if status then
				lualine.refresh()
			end
		end)
	end,
}
