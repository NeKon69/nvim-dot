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
map("n", "<C-h>", "<C-w>h", { desc = "Navigate Left", silent = true })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate Down", silent = true })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate Up", silent = true })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate Right", silent = true })
map("n", "<C-Up>", "<Cmd>resize +2<CR>", { desc = "Increase window height" })
map("n", "<C-Down>", "<Cmd>resize -2<CR>", { desc = "Decrease window height" })
map("n", "<C-Left>", "<Cmd>vertical resize -2<CR>", { desc = "Decrease window width" })
map("n", "<C-Right>", "<Cmd>vertical resize +2<CR>", { desc = "Increase window width" })
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "Git: Open LazyGit" })
map("n", "]c", function()
  if vim.wo.diff then return "]c" end
  vim.schedule(function() require("gitsigns").next_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Git: Next Hunk" })

map("n", "[c", function()
  if vim.wo.diff then return "[c" end
  vim.schedule(function() require("gitsigns").prev_hunk() end)
  return "<Ignore>"
end, { expr = true, desc = "Git: Previous Hunk" })

map("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Git: Stage Hunk" })
map("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Git: Reset Hunk" })
map("n", "<leader>hu", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Git: Undo Stage Hunk" })
map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git: Preview Hunk" }) 
map("n", "<leader>ss", "<cmd>SessionSave<CR>", { desc = "Session: Save" })
map("n", "<leader>sr", "<cmd>SessionRestore<CR>", { desc = "Session: Restore" })
map("n", "<leader>sd", "<cmd>SessionDelete<CR>", { desc = "Session: Delete" })
map("n", "qq", "<cmd>close<CR>", { desc = "Close Window/Buffer" })
vim.cmd("command! Q qa") 
map("n", "<leader>q", "<cmd>qa<CR>", { desc = "Quit Neovim" })
