local map = vim.keymap.set
local cmake_group = { name = "CMake", prefix = "<leader>c" }

map("n", "<leader>cc", "<Cmd>CMakeGenerate<CR>", { desc = "Configure Project" })
map("n", "<leader>cb", "<Cmd>CMakeBuild<CR>", { desc = "Build Project" })
map("n", "<leader>cx", "<Cmd>CMakeClean<CR>", { desc = "Clean Project (Clear Cache)" }) -- New!
map("n", "<leader>cd", "<Cmd>CMakeDebug<CR>", { desc = "Debug Target" })
map("n", "<leader>cr", "<Cmd>CMakeRun<CR>", { desc = "Run Target" })
map("n", "<leader>ct", "<Cmd>CMakeSelectLaunchTarget<CR>", { desc = "Select Target" })
map("n", "<leader>cv", "<Cmd>CMakeSelectBuildType<CR>", { desc = "Select Variant (Build Type)" })

map("n", "<leader>co", "<Cmd>CMakeOpenExecutor<CR>", { desc = "Open Output Window" }) -- New!
map("n", "<leader>cq", "<Cmd>CMakeCloseExecutor<CR>", { desc = "Close Output Window" }) -- New!
local function smart_jk(key, list_cmd)
	return function()
		local current_win = vim.fn.winnr()
		vim.cmd("wincmd " .. key)
		if current_win == vim.fn.winnr() then
			pcall(vim.cmd, list_cmd)
		end
	end
end

map("n", "<C-j>", smart_jk("j", "cnext"), { desc = "Down window or next in qf-list", silent = true })
map("n", "<C-k>", smart_jk("k", "cprevious"), { desc = "Up window or prev in qf-list", silent = true })
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Git: Open LazyGit" })
map("n", "]c", function()
	if vim.wo.diff then
		return "]c"
	end
	vim.schedule(function()
		require("gitsigns").next_hunk()
	end)
	return "<Ignore>"
end, { expr = true, desc = "Git: Next Hunk" })

map("n", "[c", function()
	if vim.wo.diff then
		return "[c"
	end
	vim.schedule(function()
		require("gitsigns").prev_hunk()
	end)
	return "<Ignore>"
end, { expr = true, desc = "Git: Previous Hunk" })

map("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Git: Stage Hunk" })
map("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git: Reset Hunk" })
map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Git: Undo Stage Hunk" })
map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git: Preview Hunk" })
map("n", "ee", "<cmd>close<CR>", { desc = "Close Window/Buffer" })
vim.cmd("command! Q qa")
map("n", "<leader>ll", "<cmd>qa<CR>", { desc = "Quit Neovim" })
map("n", "<leader>q", ":close<CR>", { desc = "Close Curren Window" })
vim.keymap.set("n", "<leader>nf", function()
	require("user.templates").create_from_template()
end, { desc = "New file from template" })
vim.api.nvim_create_autocmd("User", {
	pattern = "VeryLazy",
	callback = function()
		vim.keymap.set("n", "<leader>e", function()
			require("nvim-tree.api").tree.toggle({ float = true })
		end, { desc = "Toggle file explorer (float)", silent = true })
	end,
	desc = "Ensure nvim-tree keymap is not overridden",
})
map("n", "<leader>fo", "<cmd>Telescope oldfiles<CR>", { desc = "Find Old Files" })
map({ "n", "t" }, "<C-/>", function()
	Snacks.terminal()
end, { desc = "Toggle Terminal" })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.indentkeys:remove("<:>")
		vim.opt_local.indentkeys:remove("0#")
	end,
})
vim.keymap.set("n", "<leader>bp", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
vim.keymap.set("n", "<leader>bn", "<cmd>bnext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<leader>bb", "<C-^>", { desc = "Toggle last buffer" })
vim.api.nvim_create_autocmd("FileType", {
	pattern = "python",
	callback = function()
		vim.opt_local.indentkeys:remove("<:>")
		vim.opt_local.indentkeys:remove("0#")
		vim.opt_local.indentkeys:remove("<CR>")
	end,
})
