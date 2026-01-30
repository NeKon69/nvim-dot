return {
{
"toppair/peek.nvim",
event = { "VeryLazy" },
build = "deno task --quiet build:fast",
opts = {
auto_load = true,
close_on_bdelete = true,
syntax = true,
theme = "dark",
update_on_change = true,
app = "browser",
filetype = { "markdown", "doxygen" },
throttle_at = 200000,
throttle_time = "auto",
},
config = function(_, opts)
local peek = require("peek")
peek.setup(opts)
vim.api.nvim_create_user_command("PeekOpen", peek.open, { desc = "Open Markdown Preview" })
vim.api.nvim_create_user_command("PeekClose", peek.close, { desc = "Close Markdown Preview" })
end,
keys = {
{ "<leader>up", "<cmd>PeekOpen<cr>", desc = "Peek Preview (Open)" },
{ "<leader>uP", "<cmd>PeekClose<cr>", desc = "Peek Preview (Close)" },
},
},
}