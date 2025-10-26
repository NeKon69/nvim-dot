return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "glslls", "lua_ls" },
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					-- Форматтеры
					"clang-format",
					"stylua",
					"black",
					"rustfmt",

					-- LSP серверы
					"cmake-language-server",
					"glsl_analyzer",

					-- Линтеры
					"cmakelang",
					"cmakelint",

					-- Отладчики
					"codelldb", -- Используем codelldb вместо cpptools
					"cpptools",

					-- Утилиты
					"asmfmt",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
