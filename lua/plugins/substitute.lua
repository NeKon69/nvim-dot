return {
{
"gbprod/substitute.nvim",
event = "VeryLazy",
opts = {
highlight_substituted_text = { enabled = true, timer = 500 },
},
config = function(_, opts)
local substitute = require("substitute")
substitute.setup(opts)

-- КЛЮЧЕВОЙ ФИКС: nowait = true побеждает задержки grn/gra
vim.keymap.set("n", "gr", substitute.operator, { desc = "Substitute", nowait = true })
vim.keymap.set("n", "grr", substitute.line, { desc = "Substitute Line", nowait = true })
vim.keymap.set("x", "gr", substitute.visual, { desc = "Substitute Selection", nowait = true })

vim.keymap.set("n", "gx", require("substitute.exchange").operator, { desc = "Exchange", nowait = true })
vim.keymap.set("n", "gxx", require("substitute.exchange").line, { desc = "Exchange Line", nowait = true })
vim.keymap.set("x", "gx", require("substitute.exchange").visual, { desc = "Exchange Selection", nowait = true })
vim.keymap.set("n", "gxc", require("substitute.exchange").cancel, { desc = "Exchange Cancel", nowait = true })
end,
},
}