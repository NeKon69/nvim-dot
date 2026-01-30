return {
	{
		"folke/tokyonight.nvim",
		lazy = false,
		priority = 1000,
		config = function()
			require("tokyonight").setup({
				style = "night",
				light_style = "day",
				transparent = false,
				terminal_colors = true,
				styles = {
					comments = { italic = true },
					keywords = { italic = true },
					functions = { bold = true },
					variables = {},
				},
				lsp_semantic_tokens = true,
				on_highlights = function(hl, c)
					local keyword_color = { fg = c.purple, italic = true }
					hl["@function.call"] = keyword_color
					hl["PreProc"] = keyword_color
					hl["@keyword"] = keyword_color
					hl["@keyword.conditional"] = keyword_color
					hl["@keyword.repeat"] = keyword_color
					hl["@keyword.exception"] = keyword_color
					hl["@keyword.operator"] = keyword_color
					hl["@keyword.directive"] = keyword_color
					hl["@type.qualifier"] = keyword_color
					hl["@keyword.modifier"] = keyword_color
					hl["@attribute"] = keyword_color
					hl["@type.builtin"] = keyword_color
					hl["@function.builtin"] = keyword_color
					hl["@lsp.typemod.typeParameter.deduced"] = keyword_color
					local deduced_types = { "class", "struct", "enum", "type", "typeAlias" }
					for _, t in ipairs(deduced_types) do
						hl["@lsp.typemod." .. t .. ".deduced"] = keyword_color
						hl["@lsp.typemod." .. t .. ".deduced.readonly"] = keyword_color
					end
					hl["@lsp.mod.readonly"] = { fg = c.red }
					hl["@constant"] = { fg = c.red }
					hl["@constant.macro"] = { fg = c.red }
					hl["@lsp.type.macro"] = { fg = c.red }
					hl["@lsp.typemod.variable.globalScope"] = { fg = c.red }
					hl["@lsp.typemod.variable.static.readonly"] = { fg = c.red }
					hl["@lsp.typemod.property.static.readonly"] = { fg = c.red }
					local function_style = { fg = c.blue, bold = true }
					local method_style = { fg = c.magenta, bold = true }
					hl["@lsp.typemod.function.readonly"] = function_style
					hl["@lsp.typemod.method.readonly"] = method_style
					hl["@lsp.typemod.function.globalScope"] = function_style
					hl["@lsp.typemod.parameter.readonly"] = { fg = c.orange, bold = true }
					hl["@lsp.typemod.enumMember.readonly"] = { fg = c.green1 }
					hl["@variable"] = { fg = "#ffffff" }
					hl["@variable.parameter"] = { fg = c.orange, bold = true }
					hl["@lsp.type.variable"] = { fg = "#ffffff" }
					hl["@lsp.type.parameter"] = { fg = c.orange, bold = true }
					hl["@type"] = { fg = c.yellow }
					hl["@lsp.type.class"] = { fg = c.yellow }
					hl["@lsp.type.struct"] = { fg = c.yellow }
					hl["@lsp.type.typeAlias"] = { fg = c.yellow }
					hl["@lsp.type.typeParameter"] = { fg = c.yellow, italic = true }
					hl["@variable.member"] = { fg = c.green1 }
					hl["@lsp.type.property"] = { fg = c.green1 }
					hl["@lsp.type.enumMember"] = { fg = c.green1 }
					hl["@function"] = function_style
					hl["@lsp.type.function"] = function_style
					hl["@lsp.type.method"] = method_style
					hl["@constructor"] = function_style
					hl["@lsp.typemod.class.constructorOrDestructor"] = function_style
					hl["@namespace"] = { fg = c.cyan, italic = true }
					hl["@lsp.type.namespace"] = { fg = c.cyan, italic = true }
					hl["@variable.builtin"] = { fg = c.red }
					local type_color = { fg = c.yellow }
					hl["@lsp.typemod.class.defaultLibrary"] = type_color
					hl["@lsp.typemod.struct.defaultLibrary"] = type_color
					hl["@lsp.typemod.function.defaultLibrary"] = function_style
					hl["@lsp.typemod.method.defaultLibrary"] = method_style
					hl["@lsp.typemod.type.defaultLibrary"] = { fg = c.green1 }
					hl["@lsp.typemod.typeAlias.defaultLibrary"] = type_color
					hl["@lsp.typemod.enum.defaultLibrary"] = type_color
					hl["@lsp.type.concept"] = type_color
					hl["@constant.builtin"] = keyword_color
					hl["@boolean.cpp"] = keyword_color
					hl["@lsp.type.operator"] = {}
					hl["@operator"] = { fg = c.blue1 }
				end,
			})
			vim.cmd.colorscheme("tokyonight")
		end,
	},
	{
		"nvim-lualine/lualine.nvim",
		config = function()
			local function lualine_dap_component()
				if _G.dap_layer_active then
					return " DEBUG"
				end
				return ""
			end
			local noice_components = {
				mode = {
					require("noice").api.status.mode.get,
					cond = require("noice").api.status.mode.has,
					color = { fg = "#ff9e64" },
				},
				search = {
					require("noice").api.status.search.get,
					cond = require("noice").api.status.search.has,
					color = { fg = "#ff9e64" },
				},
			}
			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { noice_components.mode, "filename", noice_components.search },
					lualine_x = {
						{ lualine_dap_component, color = { bg = "#f7768e", fg = "#1a1b26" } },
						{
							function()
								return pcall(require, "triforce") and require("triforce.lualine").streak() or ""
							end,
						},
						{
							function()
								return pcall(require, "triforce") and require("triforce.lualine").level() or ""
							end,
						},
						"encoding",
						"fileformat",
						"filetype",
					},
					lualine_y = { "progress" },
					lualine_z = { "location" },
				},
			})
		end,
	},
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		opts = {
			preset = "modern",
			delay = 200,
			win = {
				border = "rounded",
				no_overlap = false,
				padding = { 1, 2 },
				title = true,
				title_pos = "center",
				zindex = 1000,
				col = -1,
				row = -1,
				width = 0.18,
				height = { min = 10, max = 50 },
			},
			layout = { width = { min = 10 }, spacing = 3, align = "left" },
			ignore = { "<leader>[0-9]" },
			sort = { "group", "local", "order", "mod" },
			spec = { mode = { "n", "v" } },
			icons = { breadcrumb = "»", separator = "➜", group = "+" },
		},
		config = function(_, opts)
			local wk = require("which-key")
			wk.setup(opts)
			vim.api.nvim_set_hl(0, "WhichKeyBorder", { fg = "#b464ff", bg = "NONE" })
			vim.api.nvim_set_hl(0, "WhichKey", { fg = "#cf55ff", bold = true })
			vim.api.nvim_set_hl(0, "WhichKeyGroup", { fg = "#5daeff", bold = true })
			vim.api.nvim_set_hl(0, "WhichKeySeparator", { fg = "#6c7086" })
			vim.api.nvim_set_hl(0, "WhichKeyDesc", { fg = "#ffffff" })
			vim.api.nvim_set_hl(0, "WhichKeyFloat", { bg = "#1e1e2e" })
			local hidden_harpoon_maps = {}
			for i = 1, 9 do
				table.insert(hidden_harpoon_maps, {
					string.format("<leader>%d", i),
					function()
						require("harpoon"):list():select(i)
					end,
					hidden = true,
					noremap = true,
					silent = true,
				})
			end
			table.insert(hidden_harpoon_maps, {
				"<leader>0",
				function()
					require("harpoon"):list():select(10)
				end,
				hidden = true,
				noremap = true,
				silent = true,
			})
			wk.add(hidden_harpoon_maps)
		end,
	},
}
