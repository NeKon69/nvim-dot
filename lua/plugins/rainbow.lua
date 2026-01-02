vim.api.nvim_set_hl(0, "RainbowDelimiterPastelRed", { fg = "#F7768E" })
vim.api.nvim_set_hl(0, "RainbowDelimiterVibrantOrange", { fg = "#FF9E64" })
vim.api.nvim_set_hl(0, "RainbowDelimiterSunnyYellow", { fg = "#E0AF68" })
vim.api.nvim_set_hl(0, "RainbowDelimiterFreshGreen", { fg = "#9ECE6A" })
vim.api.nvim_set_hl(0, "RainbowDelimiterCalmBlue", { fg = "#7AA2F7" })
vim.api.nvim_set_hl(0, "RainbowDelimiterDeepViolet", { fg = "#BB9AF7" })
vim.api.nvim_set_hl(0, "RainbowDelimiterBrightPink", { fg = "#FF75D4" })
return {
	"HiPhish/rainbow-delimiters.nvim",
	event = "VeryLazy",
	config = function()
		vim.g.rainbow_delimiters = {
			strategy = {
				[""] = "rainbow-delimiters.strategy.global",
				vim = "rainbow-delimiters.strategy.local",
			},
			query = {
				[""] = "rainbow-delimiters",
				lua = "rainbow-blocks",
			},
			highlight = {
				"RainbowDelimiterBrightPink",
				"RainbowDelimiterCalmBlue",
				"RainbowDelimiterSunnyYellow",
				"RainbowDelimiterFreshGreen",
				"RainbowDelimiterVibrantOrange",
				"RainbowDelimiterDeepViolet",
				"RainbowDelimiterPastelRed",
			},
			condition = function(bufnr)
				return vim.api.nvim_buf_line_count(bufnr) < 5000
			end,
		}
	end,
}
