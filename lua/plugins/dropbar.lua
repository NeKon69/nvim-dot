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

