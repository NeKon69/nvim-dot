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
					hl["@keyword.operator"] = keyword_color -- new, delete
					hl["@keyword.directive"] = keyword_color

					-- Фикс для alignas (если он попадет в атрибуты или модификаторы)
					hl["@type.qualifier"] = keyword_color
					hl["@keyword.modifier"] = keyword_color
					hl["@attribute"] = keyword_color

					-- Встроенные типы -> Фиолетовые
					hl["@type.builtin"] = keyword_color
					hl["@function.builtin"] = keyword_color

					-- ========================================================
					-- 3. AUTO И ШАБЛОНЫ
					-- ========================================================
					-- Фикс auto в лямбдах (Deduced Type Parameter -> Фиолетовый)
					hl["@lsp.typemod.typeParameter.deduced"] = keyword_color
					-- Остальные выведенные типы
					local deduced_types = { "class", "struct", "enum", "type", "typeAlias" }
					for _, t in ipairs(deduced_types) do
						hl["@lsp.typemod." .. t .. ".deduced"] = keyword_color
						hl["@lsp.typemod." .. t .. ".deduced.readonly"] = keyword_color
					end

					-- ========================================================
					-- 4. КРАСНЫЙ (READONLY)
					-- ========================================================
					hl["@lsp.mod.readonly"] = { fg = c.red }
					hl["@constant"] = { fg = c.red }
					hl["@constant.macro"] = { fg = c.red }
					hl["@lsp.type.macro"] = { fg = c.red }
					hl["@lsp.typemod.variable.globalScope"] = { fg = c.red }

					-- Статика константная
					hl["@lsp.typemod.variable.static.readonly"] = { fg = c.red }
					hl["@lsp.typemod.property.static.readonly"] = { fg = c.red }

					-- ========================================================
					-- 5. ВОССТАНОВЛЕНИЕ (ЧТОБЫ НЕ ВСЕ БЫЛО КРАСНЫМ)
					-- ========================================================
					local function_style = { fg = c.blue, bold = true }
					local method_style = { fg = c.magenta, bold = true }

					-- Функции не краснеют
					hl["@lsp.typemod.function.readonly"] = function_style
					hl["@lsp.typemod.method.readonly"] = method_style
					hl["@lsp.typemod.function.globalScope"] = function_style

					-- Аргументы -> Оранжевые
					hl["@lsp.typemod.parameter.readonly"] = { fg = c.orange, bold = true }

					-- Enum -> Зеленый
					hl["@lsp.typemod.enumMember.readonly"] = { fg = c.green1 }

					-- ========================================================
					-- 6. ОБЩИЕ ЦВЕТА
					-- ========================================================
					hl["@variable"] = { fg = "#ffffff" }
					hl["@variable.parameter"] = { fg = c.orange, bold = true }
					hl["@lsp.type.variable"] = { fg = "#ffffff" }
					hl["@lsp.type.parameter"] = { fg = c.orange, bold = true }

					-- Желтые типы
					hl["@type"] = { fg = c.yellow }
					hl["@lsp.type.class"] = { fg = c.yellow }
					hl["@lsp.type.struct"] = { fg = c.yellow }
					hl["@lsp.type.typeAlias"] = { fg = c.yellow }
					hl["@lsp.type.typeParameter"] = { fg = c.yellow, italic = true } -- T (не auto)

					-- Зеленые поля
					hl["@variable.member"] = { fg = c.green1 }
					hl["@lsp.type.property"] = { fg = c.green1 }
					hl["@lsp.type.enumMember"] = { fg = c.green1 }

					-- Функции
					hl["@function"] = function_style
					hl["@lsp.type.function"] = function_style
					hl["@lsp.type.method"] = method_style

					-- Конструкторы
					hl["@constructor"] = function_style
					hl["@lsp.typemod.class.constructorOrDestructor"] = function_style

					-- Неймспейсы
					hl["@namespace"] = { fg = c.cyan, italic = true }
					hl["@lsp.type.namespace"] = { fg = c.cyan, italic = true }

					-- This
					hl["@variable.builtin"] = { fg = c.red }

					local type_color = { fg = c.yellow } -- Или { fg = "#e0af68" } если c.yellow не тот

					hl["@lsp.typemod.class.defaultLibrary"] = type_color -- std::mutex, std::vector
					hl["@lsp.typemod.struct.defaultLibrary"] = type_color -- std::pair, std::optional
					hl["@lsp.typemod.function.defaultLibrary"] = function_style
					hl["@lsp.typemod.method.defaultLibrary"] = method_style

					hl["@lsp.typemod.type.defaultLibrary"] = { fg = c.green1 }
					hl["@lsp.typemod.typeAlias.defaultLibrary"] = type_color -- using my_type = ...
					hl["@lsp.typemod.enum.defaultLibrary"] = type_color -- std::memory_order
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
			-- Компонент для lualine
			local function lualine_dap_component()
				-- Проверяем глобальную переменную, которую мы установили в dap.lua
				if _G.dap_layer_active then
					return " DEBUG"
				end
				return ""
			end

			require("lualine").setup({
				options = {
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = { "filename" },
					lualine_x = {
						-- Вот сюда мы добавляем наш компонент!
						{
							lualine_dap_component,
							color = { bg = "#f7768e", fg = "#1a1b26" }, -- Красный из tokyonight
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

			layout = {
				width = { min = 10 },
				spacing = 3,
				align = "left",
			},
			ignore = {
				"<leader>[0-9]",
			},

			sort = { "group", "local", "order", "mod" },

			spec = {
				mode = { "n", "v" },
				-- { "<leader>f", group = "Find  " },
				-- { "<leader>g", group = "Git  " },
				-- { "<leader>c", group = "Code  " },
				-- { "<leader>l", group = "LSP  " },
				-- { "<leader>d", group = "Debug  " },
			},

			icons = {
				breadcrumb = "»",
				separator = "➜",
				group = "+",
			},
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
			-- Регистрируем наши скрытые маппинги
			wk.add(hidden_harpoon_maps)
		end,
	},
}
