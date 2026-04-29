return {
	{
		"Bekaboo/dropbar.nvim",
		event = "VimEnter",
		dependencies = {
			"nvim-tree/nvim-web-devicons",
			"nvim-telescope/telescope-fzf-native.nvim",
		},
		keys = {
			{
				"<leader>;",
				function()
					require("dropbar.api").pick()
				end,
				desc = "Winbar pick",
			},
		},
		opts = {
			bar = {
				hover = false, -- Выключаем, так как ты не захотел mousemoveevent
				update_events = vim.fn.has("nvim-0.13") == 1 and {
					buf = {
						"FileChangedShellPost",
						"TextChanged",
						"ModeChanged",
					},
				} or nil,
			},
			menu = {
				-- Настройки выпадающего меню
				quick_navigation = true,
				entry = {
					padding = { left = 1, right = 1 },
				},
			},
		},
	},
}
