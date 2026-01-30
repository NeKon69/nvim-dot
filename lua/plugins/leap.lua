return {
{
"leap.nvim",
url = "https://codeberg.org/andyg/leap.nvim",
event = "VeryLazy",
config = function()
local leap = require("leap")
leap.opts.safe_labels = "sfnut/SFNLHMUGTZ?"
leap.opts.labels = "sfnjklhodweimbuyvrgtaqpcxz/SFNJKLHODWEIMBUYVRGTAQPCXZ?"
-- s во все стороны (Current window bidirectional)
vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap)", { desc = "Leap Bidirectional" })
end,
},
{
"ggandor/leap-ast.nvim",
dependencies = { "leap.nvim", "nvim-treesitter/nvim-treesitter" },
keys = {
-- S для прыжка по AST узлам (как во Flash Treesitter)
{ "S", function() require("leap-ast").leap() end, mode = { "n", "x", "o" }, desc = "Leap AST (Treesitter)" },
},
},
}
