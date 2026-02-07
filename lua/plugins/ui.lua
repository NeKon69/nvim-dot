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
			local symbols = {
				spinner = { "⠋", "⠙", "⠹", "⠼", "⠴", "⠦", "⠧", "⠏" },
				ok = "",
				err = "",
				warn = "",
				target = "󰆧",
				profile = "",
			}

			local colors = {
				running = "#61afef",
				success = "#98be65",
				fail = "#ff6c6b",
				pending = "#ECBE7B",
				p_debug = "#d19a66",
				p_release = "#98be65",
				p_default = "#c678dd",
			}

			-- Fix Б: Палитра для радуги
			local rainbow_colors = { "#ff5d78", "#ff9b5e", "#ffc75f", "#f9f871", "#00d2fc", "#00d7bd" }

			local function get_main_task()
				local ok, overseer = pcall(require, "overseer")
				if not ok then
					return nil
				end

				local tasks = overseer.list_tasks({ include_ephemeral = true })
				if #tasks == 0 then
					return nil
				end

				local now = os.time()
				local latest_task = nil
				local latest_time = -1

				for _, t in ipairs(tasks) do
					local t_time = 0
					if t.status == "RUNNING" then
						t_time = now + 100
					elseif t.status == "PENDING" then
						t_time = t.time_start or 0
					else
						t_time = t.time_end or 0
					end

					if t_time > latest_time then
						latest_time = t_time
						latest_task = t
					end
				end

				return latest_task
			end

			local function overseer_status()
				local task = get_main_task()
				local now = os.time()

				if task then
					local t_time = (task.status == "RUNNING" or task.status == "PENDING") and (task.time_start or now)
						or (task.time_end or 0)

					local diff = os.difftime(now, t_time)

					local is_finished = (
						task.status == "SUCCESS"
						or task.status == "FAILURE"
						or task.status == "CANCELED"
					)
					if is_finished and (t_time == 0 or diff > 5) then
						task = nil
					end
				end

				if task then
					if task.status == "RUNNING" then
						-- Fix: Используем vim.loop.hrtime() для плавной анимации без зависаний
						local time = vim.loop.hrtime() / 1e9
						local frame = math.floor(time * 10) % #symbols.spinner + 1
						local spinner = symbols.spinner[frame]
						return string.format("%s Running %s", spinner, task.name)
					elseif task.status == "PENDING" then
						return string.format("%s Pending %s...", symbols.warn, task.name)
					elseif task.status == "FAILURE" or task.status == "CANCELED" then
						return string.format("%s Failed %s", symbols.err, task.name)
					elseif task.status == "SUCCESS" then
						return string.format("%s Done %s", symbols.ok, task.name)
					end
				end

				local bs = _G.BuildSystem
				if not bs then
					return "..."
				end

				local has_targets = bs.available_targets and #bs.available_targets > 0
				local t = bs.target or "Def"
				local p = bs.profile or "norm"

				if has_targets then
					return string.format("%s %s  %s %s", symbols.target, t, symbols.profile, p)
				else
					return string.format("%s %s", symbols.profile, p)
				end
			end

			local function overseer_color()
				local task = get_main_task()
				local now = os.time()

				if task then
					local t_time = (task.status == "RUNNING" or task.status == "PENDING") and (task.time_start or now)
						or (task.time_end or 0)

					local is_finished = (
						task.status == "SUCCESS"
						or task.status == "FAILURE"
						or task.status == "CANCELED"
					)
					if not (is_finished and (t_time == 0 or os.difftime(now, t_time) > 5)) then
						if task.status == "RUNNING" then
							-- Fix: Радужный цвет, меняющийся во времени
							local time = vim.loop.hrtime() / 1e9
							local idx = math.floor(time * 2) % #rainbow_colors + 1
							return { fg = rainbow_colors[idx], gui = "bold" }
						end
						if task.status == "PENDING" then
							return { fg = colors.pending, gui = "bold" }
						end
						if task.status == "SUCCESS" then
							return { fg = colors.success, gui = "bold" }
						end
						if task.status == "FAILURE" or task.status == "CANCELED" then
							return { fg = colors.fail, gui = "bold" }
						end
					end
				end

				local bs = _G.BuildSystem
				if bs and bs.profile then
					local p = bs.profile:lower()
					if p:find("debug") then
						return { fg = colors.p_debug, gui = "bold" }
					end
					if p:find("release") then
						return { fg = colors.p_release, gui = "bold" }
					end
				end
				return { fg = colors.p_default }
			end

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
					refresh = { statusline = 100 }, -- Критично для анимации (10fps)
					theme = "tokyonight",
					component_separators = { left = "", right = "" },
					section_separators = { left = "", right = "" },
				},
				sections = {
					lualine_a = { "mode" },
					lualine_b = { "branch", "diff", "diagnostics" },
					lualine_c = {
						noice_components.mode,
						"filename",
						noice_components.search,
						{
							overseer_status,
							color = overseer_color,
							on_click = function()
								vim.cmd("OverseerToggle")
							end,
						},
					},
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
