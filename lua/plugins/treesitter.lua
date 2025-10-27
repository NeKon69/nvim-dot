return {
	"nvim-treesitter/nvim-treesitter",
	build = ":TSUpdate",
	config = function()
		require("nvim-treesitter.configs").setup({
			ensure_installed = { "c", "cpp", "lua", "vim", "vimdoc", "bash", "cmake", "json", "cuda", "glsl" },

			sync_install = false,

			auto_install = true,

			highlight = {
				enable = true,
			},
			indent = { enable = true },
		})
	end,
}
