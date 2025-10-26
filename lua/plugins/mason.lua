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
					"clang-format",
					"stylua",
					"black",
					"rustfmt",
					"cmake-language-server",
					"cmakelang",

					"sonarlint-language-server",
					"cmakelint",
					"glsl_analyzer",
					"asmfmt",

					"cpptools",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
