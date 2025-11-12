return {
	"kmontocam/nvim-conda",
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		require("nvim-conda").setup({
			conda_executable = vim.fn.expand("~/miniconda3/bin/conda"),
		})

		vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
			callback = function()
				local cwd = vim.fn.getcwd()
				local main_py = cwd .. "/main.py"

				if vim.fn.filereadable(main_py) == 0 then
					return
				end

				local env_name = vim.fn.fnamemodify(cwd, ":t")

				local conda_envs = vim.fn.system("conda env list")

				if not string.match(conda_envs, env_name) then
					print("Creating conda env: " .. env_name)
					vim.fn.system(string.format("conda create -n %s python=3.11 -y", env_name))
				end

				vim.schedule(function()
					vim.cmd("CondaActivate " .. env_name)
					print("Activated conda env: " .. env_name)
				end)
			end,
		})
	end,
	keys = {
		{ "<leader>pa", "<cmd>CondaActivate<cr>", desc = "Select Conda env" },
	},
}
