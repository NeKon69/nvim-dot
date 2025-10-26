return {
	"neovim/nvim-lspconfig",
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		{ "antosha417/nvim-lsp-file-operations", config = true },
	},
	config = function()
		-- Импортируем пользовательские настройки
		local user_lspconfig = require("user.lspconfig")

		-- Новый API: используем vim.lsp.config вместо require('lspconfig')

		-- Настройка clangd (C++)
		vim.lsp.config("clangd", {
			cmd = { "clangd" },
			filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
			root_markers = {
				".clangd",
				".clang-tidy",
				".clang-format",
				"compile_commands.json",
				"compile_flags.txt",
				".git",
			},
			capabilities = user_lspconfig.capabilities,
		})

		-- Настройка glslls (GLSL)
		vim.lsp.config("glslls", {
			cmd = { "glslls", "--stdin" },
			filetypes = { "glsl", "vert", "frag", "geom", "tesc", "tese", "comp" },
			capabilities = user_lspconfig.capabilities,
		})

		-- Настройка lua_ls (Lua)
		vim.lsp.config("lua_ls", {
			cmd = { "lua-language-server" },
			filetypes = { "lua" },
			root_markers = {
				".luarc.json",
				".luarc.jsonc",
				".luacheckrc",
				".stylua.toml",
				"stylua.toml",
				"selene.toml",
				"selene.yml",
				".git",
			},
			capabilities = user_lspconfig.capabilities,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							vim.env.VIMRUNTIME,
							"${3rd}/luv/library",
						},
						checkThirdParty = false,
					},
					telemetry = {
						enable = false,
					},
				},
			},
		})

		-- Включаем LSP серверы (новый способ)
		vim.lsp.enable({ "clangd", "glslls", "lua_ls" })
	end,
}
