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
				sign = true,
				virtual_text = false,
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

		-- Кеймапы для lspsaga
		vim.keymap.set("n", "gh", "<cmd>Lspsaga finder<CR>", { desc = "LSP: Find references/implementations" })
		vim.keymap.set("n", "gp", "<cmd>Lspsaga peek_definition<CR>", { desc = "LSP: Peek definition" })
		vim.keymap.set("n", "gt", "<cmd>Lspsaga peek_type_definition<CR>", { desc = "LSP: Peek type definition" })
		vim.keymap.set("n", "<leader>ca", "<cmd>Lspsaga code_action<CR>", { desc = "LSP: Code action" })
		vim.keymap.set("n", "<leader>o", "<cmd>Lspsaga outline<CR>", { desc = "LSP: Outline" })
		vim.keymap.set("n", "<leader>ci", "<cmd>Lspsaga incoming_calls<CR>", { desc = "LSP: Incoming calls" })
		vim.keymap.set("n", "<leader>co", "<cmd>Lspsaga outgoing_calls<CR>", { desc = "LSP: Outgoing calls" })
	end,
}
