return {
	"nvimdev/lspsaga.nvim",
	event = "LspAttach",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
		"nvim-tree/nvim-web-devicons",
	},
	config = function()
		require("lspsaga").setup({
			ui = {
				border = "rounded",
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
			diagnostic = {
				on_insert = false,
				on_insert_follow = false,
			},
			finder = {
				keys = {
					vsplit = "v",
					split = "s",
					quit = "q",
				},
			},
		})

		local keymap = vim.keymap.set
		keymap("n", "gh", "<cmd>Lspsaga finder<CR>", { desc = "LSP: Find references/implementations" })
		keymap("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "LSP: Peek definition" })
		keymap("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "LSP: Peek type definition" })
		keymap("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "LSP: Code action" })
		keymap({ "n", "v" }, "<M-CR>", "<cmd>Lspsaga code_action<CR>", { desc = "LSP: Code action (Alt+Enter)" })

		keymap("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "LSP: Outline" })
		keymap("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { desc = "LSP: Incoming calls" })
		keymap("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "LSP: Outgoing calls" })
	end,
}
