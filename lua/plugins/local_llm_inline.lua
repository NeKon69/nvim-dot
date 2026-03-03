return {
	"nvim-lua/plenary.nvim",
	enabled = false,
	event = "VimEnter",
	config = function()
		require("user.local_llm_inline").setup()
	end,
}
