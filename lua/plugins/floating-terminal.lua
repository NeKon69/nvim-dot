return {
	"akinsho/toggleterm.nvim",
	version = "*",
	lazy = false,
	keys = {
		{ [[<C-\>]], "<cmd>ToggleTerm direction=float<cr>", desc = "💻 Toggle Floating Terminal" },
	},
	opts = {
		size = 20,
		open_mapping = [[<C-\>]], -- Дублируем маппинг для плагина
		hide_numbers = true,
		shade_terminals = true,
		start_in_insert = true,
		insert_mappings = true,
		terminal_mappings = true,
		persist_size = true,
		direction = "float", -- Делаем его плавающим по умолчанию
		close_on_exit = true,
		shell = vim.o.shell,
		float_opts = {
			border = "rounded",
			winblend = 0,
		},
	},
}
