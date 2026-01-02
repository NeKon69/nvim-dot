return {
	"kdheepak/lazygit.nvim",
	cmd = {
		"LazyGit",
		"LazyGitConfig",
		"LazyGitCurrentFile",
		"LazyGitFilter",
		"LazyGitFilterCurrentFile",
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		"nvim-telescope/telescope.nvim",
	},
	keys = {
		{ "<leader>gf", "<cmd>LazyGitCurrentFile<cr>", desc = "LazyGit Current File" },
		{ "<leader>gr", "<cmd>Telescope lazygit<cr>", desc = "LazyGit Repos (Telescope)" },
	},
	init = function()
		vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
		vim.g.lazygit_use_neovim_remote = 0

		vim.api.nvim_set_hl(0, "LazyGitBorder", { fg = "#fF00FF" })
		vim.api.nvim_set_hl(0, "LazyGitFloat", { bg = "none" })
	end,
	config = function()
		require("telescope").load_extension("lazygit")
	end,
}
