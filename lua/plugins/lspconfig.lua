return {
	{
		"neovim/nvim-lspconfig",
		event = { "VeryLazy" },
		dependencies = {
			"hrsh7th/cmp-nvim-lsp",
			"folke/lazydev.nvim",
		},
		config = function()
			local user_lsp = require("user.lspconfig")
			local capabilities = user_lsp.capabilities
			local function basedpyright_cmd()
				local found = vim.fn.exepath("basedpyright-langserver")
				if found ~= "" then
					return found
				end
				return vim.fn.expand("$MASON/bin/basedpyright-langserver")
			end

			vim.api.nvim_create_user_command("LspInfo", "checkhealth vim.lsp", {})

			vim.api.nvim_create_user_command("LspLog", function()
				local log_path = vim.lsp.log.get_filename()
				vim.cmd("tabnew " .. log_path)
			end, {})
			vim.api.nvim_create_user_command("LspClientsHere", function()
				local bufnr = vim.api.nvim_get_current_buf()
				local clients = vim.lsp.get_clients({ bufnr = bufnr })
				if #clients == 0 then
					vim.notify("No LSP clients attached to current buffer", vim.log.levels.INFO)
					return
				end

				local names = {}
				for _, client in ipairs(clients) do
					local sem = client.server_capabilities
							and client.server_capabilities.semanticTokensProvider
							and " sem:on"
						or " sem:off"
					table.insert(names, string.format("%s(id=%d%s)", client.name, client.id, sem))
				end
				vim.notify("LSP clients: " .. table.concat(names, ", "), vim.log.levels.INFO)
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
				capabilities = capabilities,
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
				capabilities = capabilities,
				root_markers = { "CMakeLists.txt", ".git" },
			})

			vim.lsp.config("lua_ls", {
				cmd = { "lua-language-server" },
				filetypes = { "lua" },
				capabilities = capabilities,
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
							library = vim.api.nvim_get_runtime_file("", true),
							checkThirdParty = false,
						},
						telemetry = { enable = false },
					},
				},
			})

			vim.lsp.config("basedpyright", {
				cmd = { basedpyright_cmd(), "--stdio" },
				filetypes = { "python" },
				capabilities = capabilities,
				single_file_support = true,
				root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
				root_dir = function(bufnr, on_dir)
					local fname = vim.api.nvim_buf_get_name(bufnr)
					local root = vim.fs.root(fname, { "pyproject.toml", "setup.py", "requirements.txt", ".git" })
					on_dir(root or vim.fs.dirname(fname))
				end,
				before_init = function(_, config)
					local root = config.root_dir
					if not root or root == "" then
						return
					end
					local venv_python = root .. "/.nvim/venv/bin/python"
					if vim.fn.executable(venv_python) ~= 1 then
						return
					end

					config.settings = config.settings or {}
					config.settings.python = config.settings.python or {}
					config.settings.python.pythonPath = venv_python
					config.settings.python.venvPath = root .. "/.nvim"
					config.settings.python.venv = "venv"
				end,
				settings = {
					python = {
						venvPath = ".nvim",
						venv = "venv",
						analysis = {
							autoSearchPaths = true,
							useLibraryCodeForTypes = true,
							diagnosticMode = "workspace",
						},
					},
				},
			})
			vim.g.python_lsp_server = "basedpyright"

			vim.lsp.enable({
				"clangd",
				"lua_ls",
				"basedpyright",
				"neocmake",
				"glsl_analyzer",
			})
		end,
	},
}
