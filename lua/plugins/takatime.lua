return {
	"Rtarun3606k/TakaTime",
	event = "VeryLazy",
	keys = {
		{ "<leader>ts", "<cmd>TakaStatus<CR>", desc = "TakaTime Status" },
	},
	config = function()
		local utils = require("taka-time.utils")

		utils.get_binary_path_dahboard = utils.get_binary_path_dahboard
			or function()
				return utils.get_binary_path(utils.BinaryEnum.DASHBOARD)
			end

		utils.ensure_binary_dashboard = utils.ensure_binary_dashboard
			or function()
				return utils.ensure_binary(utils.BinaryEnum.DASHBOARD)
			end

		require("taka-time").setup({
			debug = false,
		})

		pcall(vim.api.nvim_del_augroup_by_name, "TakaTimeExit")
	end,
}
