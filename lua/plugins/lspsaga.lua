return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	opts = {
		ui = {
			border = "rounded",
			kind = {},
			code_action = "💡",
		},
		lightbulb = {
			enable = true,
			sign = false, -- Отключаем знаки лампочки, чтобы не провоцировать появление колонки
			virtual_text = true,
		},
		code_action = {
			num_shortcut = true,
			show_server_name = true,
			keys = {
				quit = "q",
				exec = "<CR>",
			},
		},
		finder = {
			keys = {
				vsplit = "v",
				split = "s",
				quit = "q",
				shuttle = "<C-j>",
			},
		},
		rename = { in_select = true },
		symbol_in_winbar = { enable = false },
	},
	config = function(_, opts)
		require("lspsaga").setup(opts)

		-- 1. ЦВЕТА: Твой неоновый розовый (#fa6fff)
		-- Синхронизируем фон, чтобы даже если колонка знаков появится, она была невидимой
		local nf_hl = vim.api.nvim_get_hl(0, { name = "NormalFloat" })
		local nf_bg = nf_hl.bg
		local neon_pink = "#fa6fff"

		vim.api.nvim_set_hl(0, "SagaNormal", { bg = nf_bg })
		vim.api.nvim_set_hl(0, "SagaBorder", { fg = neon_pink, bg = nf_bg })
		vim.api.nvim_set_hl(0, "HoverBorder", { fg = neon_pink, bg = nf_bg })
		-- Принудительно красим фон колонки знаков в цвет окна
		vim.api.nvim_set_hl(0, "SignColumn", { bg = nf_bg })

		-- 2. ФИКСЕР ОКОН (Race Condition Killer)
		local function apply_float_fixes(winid)
			if not winid or not vim.api.nvim_win_is_valid(winid) then
				return
			end
			local buf = vim.api.nvim_win_get_buf(winid)

			-- Проверяем, что это Hover/Saga окно (markdown + nofile)
			if vim.bo[buf].filetype == "markdown" and vim.bo[buf].buftype == "nofile" then
				-- Убиваем wrap, который Сага форсит в коде
				vim.wo[winid].wrap = false
				-- Убиваем колонку знаков (текст прижмется к краю)
				vim.wo[winid].signcolumn = "no"
				-- Убиваем остальной мусор
				vim.wo[winid].number = false
				vim.wo[winid].relativenumber = false
				vim.wo[winid].foldcolumn = "0"

				-- Ядерный удар: если кто-то (линтер) уже успел поставить знаки, удаляем их
				pcall(vim.fn.sign_unplace, "*", { buffer = buf })
			end
		end

		local saga_fix_group = vim.api.nvim_create_augroup("SagaFloatFixer", { clear = true })

		vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
			group = saga_fix_group,
			callback = function(args)
				-- schedule нужен, чтобы дождаться пока Сага закончит рисовать окно
				vim.schedule(function()
					-- Если мы попали в плавающее окно или оно только что открылось
					local winid = vim.fn.bufwinid(args.buf)
					if winid > 0 then
						apply_float_fixes(winid)
					end

					-- Дополнительная проверка текущего окна
					local cur_win = vim.api.nvim_get_current_win()
					if vim.api.nvim_win_get_config(cur_win).relative ~= "" then
						apply_float_fixes(cur_win)
					end
				end)
			end,
		})
	end,
}
