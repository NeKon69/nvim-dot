return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				ui = {
					border = "rounded",
				},
			})
		end,
	},
	{
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("mason-lspconfig").setup({
				ensure_installed = { "clangd", "lua_ls" },
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"clangd",
					"lua-language-server",
					"pyright",
					"cmake-language-server",
					"glsl_analyzer",
					"stylua",
					"clang-format",
					"black",
					"rustfmt",
					"jq",
					"selene",
					"ruff",
					"jsonlint",
					"markdownlint",
					"codespell",
					"cmakelang",
					"cmakelint",
					"codelldb",
					"asmfmt",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
