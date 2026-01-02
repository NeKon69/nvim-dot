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
			sign = false,
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
		rename = {
			in_select = true,
		},
		symbol_in_winbar = {
			enable = false,
		},
	},
	config = function(_, opts)
		require("lspsaga").setup(opts)

		vim.api.nvim_set_hl(0, "SagaBorder", { fg = "#FF00FF" })
		vim.api.nvim_set_hl(0, "HoverBorder", { fg = "#FF00FF" })

		vim.api.nvim_create_autocmd("LspAttach", {
			group = vim.api.nvim_create_augroup("LspsagaConfig", { clear = true }),
			callback = function(event)
				local bufnr = event.buf
				local keymap_opts = { buffer = bufnr, silent = true }

				vim.keymap.set("n", "gd", "<cmd>Lspsaga goto_definition<CR>", keymap_opts)
				vim.keymap.set("n", "gr", "<cmd>Lspsaga finder<CR>", keymap_opts)
				vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", keymap_opts)
				vim.keymap.set("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", keymap_opts)
				vim.keymap.set("n", "K", "<cmd>Lspsaga hover_doc<CR>", keymap_opts)
				vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", keymap_opts)
				vim.keymap.set({ "n", "v" }, "<M-CR>", "<cmd>Lspsaga code_action<CR>", keymap_opts)
				vim.keymap.set("n", "<leader>cr", "<cmd>Lspsaga rename<CR>", keymap_opts)
				vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", keymap_opts)
				vim.keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", keymap_opts)
				vim.keymap.set("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", keymap_opts)
				vim.keymap.set("n", "[d", "<cmd>Lspsaga diagnostic_jump_prev<CR>", keymap_opts)
				vim.keymap.set("n", "]d", "<cmd>Lspsaga diagnostic_jump_next<CR>", keymap_opts)

				local hover_timer = nil
				local wait_time = 500
				vim.api.nvim_create_autocmd("CursorHold", {
					buffer = bufnr,
					callback = function()
						if vim.fn.mode() == "n" and vim.fn.pumvisible() == 0 then
							if hover_timer then
								vim.fn.timer_stop(hover_timer)
							end
							hover_timer = vim.fn.timer_start(wait_time, function()
								local hover = require("lspsaga.hover")
								if not (hover.winid and vim.api.nvim_win_is_valid(hover.winid)) then
									vim.cmd("Lspsaga hover_doc ++silent")
								end
							end)
						end
					end,
				})

				vim.api.nvim_create_autocmd("CursorMoved", {
					buffer = bufnr,
					callback = function()
						if hover_timer then
							vim.fn.timer_stop(hover_timer)
						end
					end,
				})
			end,
		})
		vim.api.nvim_create_autocmd("BufWinEnter", {
			group = vim.api.nvim_create_augroup("SagaFixLineWrap", { clear = true }),
			callback = function(event)
				if vim.bo[event.buf].filetype == "markdown" then
					vim.wo[0].wrap = false
				end
			end,
		})
	end,
}
