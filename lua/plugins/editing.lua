return {
	{ "numToStr/Comment.nvim", opts = {}, lazy = false },
	{
		"kylechui/nvim-surround",
		version = "*",
		event = "VeryLazy",
		config = function() require("nvim-surround").setup({}) end,
	},
	{
		"echasnovski/mini.pairs",
		version = "*",
		event = "VeryLazy",
		config = function() require("mini.pairs").setup() end,
	},
	{
		"folke/snacks.nvim",
		opts = {},
		init = function()
			local autosave_group = vim.api.nvim_create_augroup("AutosaveOnFocus", { clear = true })

			vim.api.nvim_create_autocmd("FocusLost", {
				group = autosave_group,
				pattern = "*",
				callback = function()
					vim.cmd("silent! wa")
					local ok, persistence = pcall(require, "persistence")
					if ok then
						pcall(persistence.save)
					end
				end,
			})

			vim.api.nvim_create_autocmd("VimLeavePre", {
				callback = function()
					vim.api.nvim_del_augroup_by_name("AutosaveOnFocus")
				end,
			})
		end,
	},
}
