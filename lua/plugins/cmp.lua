return {
	"hrsh7th/nvim-cmp",
	event = { "InsertEnter", "CmdlineEnter" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"hrsh7th/cmp-buffer",
		"hrsh7th/cmp-path",
		"L3MON4D3/LuaSnip",
		"saadparwaiz1/cmp_luasnip",
		"onsails/lspkind.nvim",
		"hrsh7th/cmp-cmdline",
	},
	config = function()
		local cmp = require("cmp")
		local lspkind = require("lspkind")
		local luasnip = require("luasnip")

		-- Твой неоновый розовый
		local neon_pink = "#fa6fff"

		vim.api.nvim_set_hl(0, "CmpBorder", { fg = neon_pink, bg = "NONE" })
		vim.api.nvim_set_hl(0, "HoverBorder", { fg = neon_pink, bg = "NONE" })

		local window_opts = {
			completion = cmp.config.window.bordered({
				border = "rounded",
				winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder,CursorLine:PmenuSel,Search:None",
			}),
			documentation = cmp.config.window.bordered({
				border = "rounded",
				winhighlight = "Normal:NormalFloat,FloatBorder:CmpBorder,Search:None",
			}),
		}

		cmp.setup({
			completion = {
				completeopt = "menu,menuone,noselect",
			},
			snippet = {
				expand = function(args)
					luasnip.lsp_expand(args.body)
				end,
			},
			sources = cmp.config.sources({
				{ name = "nvim_lsp" },
				{ name = "luasnip" },
			}, {
				{ name = "buffer" },
				{ name = "path" },
			}),
			formatting = {
				format = lspkind.cmp_format({
					mode = "symbol",
					maxwidth = 50,
					ellipsis_char = "...",
				}),
			},
			mapping = {
				["<CR>"] = cmp.mapping.confirm({ select = false }),
				["<C-Space>"] = cmp.mapping.complete(),
				["<M-s>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_next_item()
					elseif luasnip.expand_or_jumpable() then
						luasnip.expand_or_jump()
					else
						fallback()
					end
				end, { "i", "s" }),
				["<M-w>"] = cmp.mapping(function(fallback)
					if cmp.visible() then
						cmp.select_prev_item()
					elseif luasnip.jumpable(-1) then
						luasnip.jump(-1)
					else
						fallback()
					end
				end, { "i", "s" }),
			},
			window = {
				completion = window_opts.completion,
				documentation = window_opts.documentation,
			},
		})

		cmp.setup.cmdline("/", {
			mapping = cmp.mapping.preset.cmdline(),
			sources = { { name = "buffer" } },
			window = { completion = window_opts.completion },
		})

		cmp.setup.cmdline(":", {
			mapping = cmp.mapping.preset.cmdline({
				["<CR>"] = cmp.mapping(function(fallback)
					if cmp.visible() and cmp.get_selected_entry() then
						cmp.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true })
					else
						fallback()
					end
				end, { "c" }),
			}),
			sources = cmp.config.sources({ { name = "path" } }, { { name = "cmdline" } }),
			window = { completion = window_opts.completion },
		})
		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = vim.api.nvim_create_augroup("SagaCustomFix", { clear = true }),
			callback = function(opt)
				if vim.bo[opt.buf].filetype == "markdown" and vim.bo[opt.buf].buftype == "nofile" then
					-- Функция-фиксер
					local function apply_fix()
						local winid = vim.fn.bufwinid(opt.buf)
						if winid and winid > 0 and vim.api.nvim_win_is_valid(winid) then
							vim.wo[winid].wrap = false
							vim.wo[winid].signcolumn = "no"
							vim.wo[winid].number = false
							vim.wo[winid].relativenumber = false
							vim.wo[winid].foldcolumn = "0"
						end
					end

					-- Запускаем сразу
					apply_fix()

					-- Запускаем через 10мс (когда Сага обычно заканчивает)
					vim.defer_fn(apply_fix, 10)

					-- И на всякий случай через 100мс (если лагает LSP/рендерер)
					vim.defer_fn(apply_fix, 100)
				end
			end,
		})
	end,
}
