return {
	"nvim-treesitter/nvim-treesitter",
	version = "v0.9.3", -- Фиксируем стабильную версию
	build = ":TSUpdate",
	dependencies = {
		"nvim-treesitter/nvim-treesitter-context",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	config = function()
		if vim.fn.has("nvim-0.13") == 1 then
			local query = require("vim.treesitter.query")
			local html_script_type_languages = {
				importmap = "json",
				module = "javascript",
				["application/ecmascript"] = "javascript",
				["text/ecmascript"] = "javascript",
			}
			local non_filetype_match_injection_language_aliases = {
				ex = "elixir",
				pl = "perl",
				sh = "bash",
				uxn = "uxntal",
				ts = "typescript",
			}

			local function get_parser_from_markdown_info_string(injection_alias)
				local match = vim.filetype.match({ filename = "a." .. injection_alias })
				return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
			end

			local function capture_nodes(match, capture_id)
				local nodes = match[capture_id]
				if not nodes then
					return nil
				end

				if type(nodes) == "table" then
					return nodes
				end

				return { nodes }
			end

			local function single_node(match, capture_id)
				local nodes = capture_nodes(match, capture_id)
				if not nodes or #nodes == 0 then
					return nil
				end

				return nodes[1]
			end

			-- Neovim 0.13 passes predicate captures as node lists. The pinned
			-- nvim-treesitter override still expects a single node and crashes.
			query.add_predicate("has-ancestor?", function(match, _, _, predicate)
				local nodes = capture_nodes(match, predicate[2])
				if not nodes or #nodes == 0 then
					return true
				end

				for _, node in ipairs(nodes) do
					if node:__has_ancestor(predicate) then
						return true
					end
				end

				return false
			end, { force = true })

			query.add_predicate("has-parent?", function(match, _, _, predicate)
				local nodes = capture_nodes(match, predicate[2])
				if not nodes or #nodes == 0 then
					return true
				end

				local parent_types = { unpack(predicate, 3) }
				for _, node in ipairs(nodes) do
					local parent = node:parent()
					if parent and vim.list_contains(parent_types, parent:type()) then
						return true
					end
				end

				return false
			end, { force = true })

			query.add_directive("set-lang-from-mimetype!", function(match, _, bufnr, predicate, metadata)
				local node = single_node(match, predicate[2])
				if not node then
					return
				end

				local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
				local configured = html_script_type_languages[type_attr_value]
				if configured then
					metadata["injection.language"] = configured
				else
					local parts = vim.split(type_attr_value, "/", {})
					metadata["injection.language"] = parts[#parts]
				end
			end, { force = true })

			query.add_directive("set-lang-from-info-string!", function(match, _, bufnr, predicate, metadata)
				local node = single_node(match, predicate[2])
				if not node then
					return
				end

				local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
				metadata["injection.language"] = get_parser_from_markdown_info_string(injection_alias)
			end, { force = true })

			query.add_directive("downcase!", function(match, _, bufnr, predicate, metadata)
				local capture_id = predicate[2]
				local node = single_node(match, capture_id)
				if not node then
					return
				end

				local node_metadata = metadata[capture_id]
				local text = vim.treesitter.get_node_text(node, bufnr, { metadata = node_metadata }) or ""
				metadata[capture_id] = node_metadata or {}
				metadata[capture_id].text = string.lower(text)
			end, { force = true })

			query.add_directive("trim!", function(match, _, bufnr, predicate, metadata)
				local capture_id = predicate[2]
				local node = single_node(match, capture_id)
				if not node then
					return
				end

				local trim_start_lines = predicate[3] == "1"
				local trim_start_cols = predicate[4] == "1"
				local trim_end_lines = predicate[5] == "1" or not predicate[3]
				local trim_end_cols = predicate[6] == "1"

				local start_row, start_col, end_row, end_col = node:range()
				local node_text = vim.split(vim.treesitter.get_node_text(node, bufnr), "\n")
				if end_col == 0 then
					node_text[#node_text + 1] = ""
				end

				local end_idx = #node_text
				local start_idx = 1

				if trim_end_lines then
					while end_idx > 0 and node_text[end_idx]:find("^%s*$") do
						end_idx = end_idx - 1
						end_row = end_row - 1
						end_col = end_idx > 0 and #node_text[end_idx] or 0
					end
				end

				if trim_end_cols then
					if end_idx == 0 then
						end_row = start_row
						end_col = start_col
					else
						local whitespace_start = node_text[end_idx]:find("(%s*)$")
						end_col = (whitespace_start - 1) + (end_idx == 1 and start_col or 0)
					end
				end

				if trim_start_lines then
					while start_idx <= end_idx and node_text[start_idx]:find("^%s*$") do
						start_idx = start_idx + 1
						start_row = start_row + 1
						start_col = 0
					end
				end

				if trim_start_cols and node_text[start_idx] then
					local _, whitespace_end = node_text[start_idx]:find("^(%s*)")
					whitespace_end = whitespace_end or 0
					start_col = (start_idx == 1 and start_col or 0) + whitespace_end
				end

				if start_row < end_row or (start_row == end_row and start_col <= end_col) then
					metadata[capture_id] = metadata[capture_id] or {}
					metadata[capture_id].range = { start_row, start_col, end_row, end_col }
				end
			end, { force = true })
		end

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
