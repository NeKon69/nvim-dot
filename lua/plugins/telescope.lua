return {
	"nvim-telescope/telescope.nvim",
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- Адаптер для Telescope, чтобы перехватывать vim.ui.select (ФИКС UI БАГА)
		"nvim-telescope/telescope-ui-select.nvim",
		-- Установленный плагин для быстрого поиска
		"nvim-telescope/telescope-fzf-native.nvim",
	},
	config = function()
		local builtin = require("telescope.builtin")
		local telescope = require("telescope")

		telescope.setup({
			defaults = {
				prompt_prefix = "   ",
				selection_caret = " ", -- Твоя иконка + пробел для отступа
				entry_prefix = "  ",
				multi_icon = " ",

				dynamic_preview_title = true,

				path_display = { "smart" },
				wrap_results = false,

				-- === Layout ===
				layout_strategy = "horizontal",
				sorting_strategy = "ascending",
				selection_strategy = "follow",
				layout_config = {
					horizontal = {
						prompt_position = "top",
						preview_width = 0.55,
					},
					vertical = {
						mirror = false,
					},
					width = 0.87,
					height = 0.80,
					preview_cutoff = 120,
				},

				border = true,
				borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
				color_devicons = true,

				prompt_title = "Search",
				results_title = "Files",

				file_ignore_patterns = { "node_modules", ".git/" },
			},
			-- === КОНФИГУРАЦИЯ РАСШИРЕНИЙ ===
			extensions = {
				-- Настройка FZF-Native (для ускорения)
				fzf = {
					fuzzy = true,
					override_generic_sorter = true,
					override_file_sorter = true,
					case_mode = "smart_case",
				},
				-- Настройка UI-Select (для vim.ui.select)
				["ui-select"] = {
					require("telescope.themes").get_dropdown({
						-- Здесь можно настроить внешний вид, если нужно
					}),
				},
			},
		})

		-- === ПОДКЛЮЧЕНИЕ РАСШИРЕНИЙ ===
		require("telescope").load_extension("fzf")
		require("telescope").load_extension("ui-select") -- Заменяет vim.ui.select на Telescope

		-- Цвета (Vim API)
		vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#5daeff", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#b464ff", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#cf55ff", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#fa6fff", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "#ff5555", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ffea00", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeResultsComment", { fg = "#6c7086", bg = "NONE" })
		vim.api.nvim_set_hl(0, "TelescopeResultsIdentifier", { fg = "#ffffff", bg = "NONE", bold = true })
	end,
}
