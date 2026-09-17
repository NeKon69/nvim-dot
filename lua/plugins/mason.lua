return {
	{
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup({
				PATH = "skip",
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
				ensure_installed = { "lua_ls" },
				automatic_enable = false,
			})
		end,
	},
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		config = function()
			require("mason-tool-installer").setup({
				ensure_installed = {
					"lua-language-server",
					"glsl_analyzer",
					"neocmakelsp",
					"neocmake",
					"stylua",
					"black",
					"rustfmt",
					"jq",
					"ruff",
					"jsonlint",
					"markdownlint",
					"codespell",
					"cmakelang",
					"cmakelint",
					"codelldb",
					"debugpy",
					"asmfmt",
				},
				auto_update = false,
				run_on_start = true,
			})
		end,
	},
}
