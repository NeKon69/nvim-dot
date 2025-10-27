return {
	"nvimdev/dashboard-nvim",
	event = "VimEnter",
	dependencies = { "nvim-tree/nvim-web-devicons" },
	config = function()
		require("dashboard").setup({
			theme = "hyper",
			config = {
				week_header = {
					enable = true,
				},
				shortcut = {
					{ desc = " Update", group = "@property", action = "Lazy update", key = "u" },
					{ desc = " Find File", group = "Label", action = "Telescope find_files", key = "f" },
					{ desc = " Old Files", group = "Number", action = "Telescope oldfiles", key = "o" },
					{ desc = " Find Word", group = "DiagnosticHint", action = "Telescope live_grep", key = "g" },
				},
				footer = {},
			},
		})
	end,
}
