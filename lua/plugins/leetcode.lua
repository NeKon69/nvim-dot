local leet_arg = "leetcode.nvim"

return {
{
"kawre/leetcode.nvim",
build = ":TSUpdate html",
dependencies = {
"nvim-telescope/telescope.nvim",
"nvim-lua/plenary.nvim",
"MunifTanjim/nui.nvim",
"nvim-tree/nvim-web-devicons",
},
-- Загружаем либо по аргументу, либо по команде Leet
lazy = vim.fn.argv(0, -1) ~= leet_arg,
cmd = "Leet",
opts = {
arg = leet_arg,
lang = "cpp",
storage = {
home = vim.fn.stdpath("data") .. "/leetcode",
cache = vim.fn.stdpath("cache") .. "/leetcode",
},
plugins = {
-- Включаем true, чтобы не ругался на открытые буферы (дашборд и т.д.)
non_standalone = true, 
},
injector = {
["cpp"] = {
before = { "#include <bits/stdc++.h>", "using namespace std;" },
},
},
picker = {
provider = "telescope",
},
},
},
}
