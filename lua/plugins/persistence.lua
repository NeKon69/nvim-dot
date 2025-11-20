return {
	"folke/persistence.nvim",
	event = "BufReadPre",
	opts = {
		dir = vim.fn.stdpath("state") .. "/sessions/",
		need = 0,
		branch = false,
	},
	init = function()
		local persistence = require("persistence")

		vim.api.nvim_create_autocmd("VimEnter", {
			nested = true,
			callback = function()
				local cwd = vim.fn.getcwd()
				local ignore_dirs = {
					vim.fn.expand("~"),
					vim.fn.expand("~/Downloads"),
					"/tmp",
					"/private/tmp",
					"/",
				}
				for _, dir in ipairs(ignore_dirs) do
					if cwd == dir then
						require("persistence").stop()
						return
					end
				end

				if vim.fn.argc() == 0 and not vim.g.started_with_stdin then
					persistence.load()
				elseif vim.fn.argc() > 0 then
					local current_file = vim.fn.expand("%:p")

					persistence.load()

					if current_file ~= "" then
						vim.cmd("edit " .. vim.fn.fnameescape(current_file))
					end
				end
			end,
		})
	end,
}
