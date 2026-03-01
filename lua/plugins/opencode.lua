return {
	{
		"nickjvandyke/opencode.nvim",
		cmd = { "Opencode", "OpencodeChat" },
		keys = {
			{
				"<leader>ac",
				function()
					require("opencode").toggle()
				end,
				desc = "Opencode Toggle",
			},
			{
				"<M-[>",
				function()
					require("opencode").toggle()
				end,
				mode = { "n", "t" },
				desc = "Opencode Toggle",
			},
			{
				"<leader>aa",
				function()
					require("opencode").select()
				end,
				desc = "Opencode Actions",
			},
		},
		config = function()
			local opencode_cmd = "opencode --port"

			local function apply_opencode_keymaps(buf)
				local opts = { buffer = buf }
				vim.keymap.set("n", "<C-u>", function()
					require("opencode").command("session.half.page.up")
				end, vim.tbl_extend("force", opts, { desc = "Scroll up half page" }))
				vim.keymap.set("n", "<C-d>", function()
					require("opencode").command("session.half.page.down")
				end, vim.tbl_extend("force", opts, { desc = "Scroll down half page" }))
				vim.keymap.set("n", "gg", function()
					require("opencode").command("session.first")
				end, vim.tbl_extend("force", opts, { desc = "Go to first message" }))
				vim.keymap.set("n", "G", function()
					require("opencode").command("session.last")
				end, vim.tbl_extend("force", opts, { desc = "Go to last message" }))
				vim.keymap.set("n", "<Esc>", function()
					require("opencode").command("session.interrupt")
				end, vim.tbl_extend("force", opts, { desc = "Interrupt current session (esc)" }))
			end

			local terminal_opts = {
				win = {
					position = "float",
					enter = true,
					border = "rounded",
					width = 0.9,
					height = 0.9,
					on_buf = function(win)
						apply_opencode_keymaps(win.buf)
					end,
				},
				start_insert = true,
				auto_insert = true,
			}

			vim.g.opencode_opts = {
				server = {
					port = 27100,
					start = function()
						require("snacks.terminal").open(opencode_cmd, terminal_opts)
					end,
					stop = function()
						local terminal = require("snacks.terminal").get(
							opencode_cmd,
							vim.tbl_extend("force", terminal_opts, { create = false })
						)
						if terminal then
							terminal:close()
						end
					end,
					toggle = function()
						require("snacks.terminal").toggle(opencode_cmd, terminal_opts)
					end,
				},
			}
			vim.o.autoread = true
		end,
	},
}
