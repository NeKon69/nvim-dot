return {
	"Rtarun3606k/TakaTime",
	event = "VeryLazy",
	keys = {
		{ "<leader>ts", "<cmd>TakaStatus<CR>", desc = "TakaTime Status" },
	},
	config = function()
		require("taka-time").setup({
			debug = false,
		})

		pcall(vim.api.nvim_del_augroup_by_name, "TakaTimeExit")
	end,
}
