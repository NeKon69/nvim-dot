return {
	"lewis6991/gitsigns.nvim",
	event = "VeryLazy",
	opts = {
		signs = {
			add = { text = "▎" },
			change = { text = "▎" },
			delete = { text = "" },
			topdelete = { text = "" },
			changedelete = { text = "▎" },
			untracked = { text = "▎" },
		},
		signcolumn = true,
		numhl = true,
		linehl = false,
		word_diff = false,
		current_line_blame = false,
		current_line_blame_opts = {
			virt_text_pos = "eol",
			delay = 1000,
		},
	},
	config = function(_, opts)
		require("gitsigns").setup(opts)

		vim.keymap.set("n", "]c", function()
			if vim.wo.diff then
				return "]c"
			end
			vim.schedule(function()
				require("gitsigns").nav_hunk("next")
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Next Hunk" })

		vim.keymap.set("n", "[c", function()
			if vim.wo.diff then
				return "[c"
			end
			vim.schedule(function()
				require("gitsigns").nav_hunk("prev")
			end)
			return "<Ignore>"
		end, { expr = true, desc = "Previous Hunk" })

		local gs = require("gitsigns")
		vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })
		vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })
		vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })
		vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Blame Line" })
		vim.keymap.set("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle Blame" })
	end,
}
