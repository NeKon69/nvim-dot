return {
	"mfussenegger/nvim-treehopper",
	dependencies = { "nvim-treesitter/nvim-treesitter" },
	config = function()
		local tsht = require("tsht")

		-- Прыжок в НАЧАЛО (Normal mode)
		vim.keymap.set("n", "gm", function()
			tsht.nodes()
			if vim.fn.mode():match("[vV]") then
				vim.cmd("normal! o") -- Перекидываем курсор в начало
				local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
				vim.api.nvim_feedkeys(esc, "n", true)
			end
		end, { desc = "Jump to Start of Node" })

		-- Прыжок в КОНЕЦ (Normal mode)
		vim.keymap.set("n", "gM", function()
			tsht.nodes()
			if vim.fn.mode():match("[vV]") then
				-- В визуальном режиме курсор и так в конце, просто выходим
				local esc = vim.api.nvim_replace_termcodes("<Esc>", true, false, true)
				vim.api.nvim_feedkeys(esc, "n", true)
			end
		end, { desc = "Jump to End of Node" })

		vim.keymap.set("n", "m", tsht.nodes, { desc = "Select Node (Visual)" })
		vim.keymap.set("x", "m", tsht.nodes)
	end,
}
