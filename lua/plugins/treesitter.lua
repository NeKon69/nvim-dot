return {
	"nvim-treesitter/nvim-treesitter",
	version = "v0.9.3", -- Фиксируем стабильную версию
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		-- Настройка путей установки
		local install = require("nvim-treesitter.install")
		install.prefer_git = true
		install.parser_install_dir = vim.fn.stdpath("data") .. "/site"

		-- ВАЖНО: используем "configs" с буквой S на конце
		require("nvim-treesitter.configs").setup({
			-- Список языков из твоего старого конфига
			ensure_installed = {
				"c",
				"cpp",
				"python",
				"lua",
				"vim",
				"vimdoc",
				"bash",
				"cmake",
				"json",
				"cuda",
				"glsl",
				"markdown",
				"markdown_inline",
				"doxygen",
				"html",
				"xml",
				"comment",
				"query", -- Добавил query, чтобы не было ошибок в самом триситтере
			},

			sync_install = false,
			auto_install = true,

			highlight = {
				enable = true, -- Это само выключит старый vim-хайлайт и запустит TS
				additional_vim_regex_highlighting = false,
			},
			indent = { enable = true },

			textobjects = {
				select = {
					enable = true,
					lookahead = true,
					keymaps = {
						["aa"] = "@parameter.outer",
						["ia"] = "@parameter.inner",
						["af"] = "@function.outer",
						["if"] = "@function.inner",
						["ac"] = "@class.outer",
						["ic"] = "@class.inner",
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["]m"] = "@function.outer",
						["]]"] = "@class.outer",
					},
					goto_next_end = {
						["]M"] = "@function.outer",
						["]["] = "@class.outer",
					},
					goto_previous_start = {
						["[m"] = "@function.outer",
						["[["] = "@class.outer",
					},
					goto_previous_end = {
						["[M"] = "@function.outer",
						["[]"] = "@class.outer",
					},
				},
			},
		})
	end,
}
