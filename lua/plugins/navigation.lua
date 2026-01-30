return {
{
"nvim-treesitter/nvim-treesitter-context",
event = "VeryLazy",
opts = {
enable = true,
max_lines = 3,
min_window_height = 20,
line_numbers = true,
multiline_threshold = 1,
trim_scope = "outer",
mode = "topline",
separator = nil,
},
keys = {
{
"<leader>ut",
function()
require("treesitter-context").toggle()
end,
desc = "Toggle Treesitter Context",
},
},
},
}
