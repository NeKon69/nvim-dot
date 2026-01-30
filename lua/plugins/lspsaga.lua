return {
"nvimdev/lspsaga.nvim",
event = "LspAttach",
dependencies = {
"nvim-treesitter/nvim-treesitter",
"nvim-tree/nvim-web-devicons",
},
opts = {
ui = {
border = "rounded",
kind = {},
code_action = "💡",
},
lightbulb = {
enable = true,
sign = false,
virtual_text = true,
},
code_action = {
num_shortcut = true,
show_server_name = true,
keys = {
quit = "q",
exec = "<CR>",
},
},
finder = {
keys = {
vsplit = "v",
split = "s",
quit = "q",
shuttle = "<C-j>",
},
},
rename = { in_select = true },
symbol_in_winbar = { enable = false },
},
config = function(_, opts)
require("lspsaga").setup(opts)
vim.api.nvim_set_hl(0, "SagaBorder", { fg = "#FF00FF" })
vim.api.nvim_set_hl(0, "HoverBorder", { fg = "#FF00FF" })
end,
}
