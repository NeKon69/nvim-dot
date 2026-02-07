return {
	{
		"neovim/nvim-lspconfig",
		event = { "VeryLazy" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
		},
		config = function()
			require("user.lspconfig")

			vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})

			vim.api.nvim_create_user_command("LspLog", function()
				local log_path = vim.lsp.log.get_filename()
				vim.cmd("tabnew " .. log_path)
			end, {})

			vim.lsp.config("clangd", {
				cmd = {
					"clangd",
					"--background-index",
					"--clang-tidy",
					"--query-driver=/opt/cuda/bin/nvcc,/usr/bin/c++,/usr/bin/g++,/usr/bin/clang++",
					"--header-insertion=iwyu",
					"--completion-style=detailed",
				},
				filetypes = { "c", "cpp", "objc", "objcpp", "cuda" },
				root_markers = {
					".clangd",
					".clang-tidy",
					".clang-format",
					"compile_commands.json",
					"compile_flags.txt",
					".git",
				},
			})

			-- Neocmake (наш новый Rust-сервер вместо битого питоновского)
			vim.lsp.config("neocmake", {
				cmd = { "neocmakelsp", "stdio" },
				filetypes = { "cmake" },
				root_markers = { "CMakeLists.txt", ".git" },
			})

			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				root_markers = {
					".luarc.json",
					".luarc.jsonc",
					".luacheckrc",
					".stylua.toml",
					".git",
				},
				settings = {
					Lua = {
						runtime = { version = "LuaJIT" },
						diagnostics = { globals = { "vim" } },
						workspace = {
							library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("pyright", {
				cmd = { "pyright-langserver", "--stdio" },
				filetypes = { "python" },
				root_markers = { "pyproject.toml", "setup.py", ".git" },
				settings = {
					python = {
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			})

			vim.lsp.enable({
				"clangd",
				"lua_ls",
				"pyright",
				"neocmake",
				"glsl_analyzer",
			})
		end,
	},
}
