return {
{
"mrjones2014/smart-splits.nvim",
lazy = false, -- Для мгновенной готовности навигации
opts = {
at_edge = "stop",
default_amount = 3,
},
keys = {
-- Перемещение (заменяем стандартные Ctrl-hjkl)
{ "<C-h>", function() require("smart-splits").move_cursor_left() end, desc = "Move to Left Split" },
{ "<C-j>", function() require("smart-splits").move_cursor_down() end, desc = "Move to Below Split" },
{ "<C-k>", function() require("smart-splits").move_cursor_up() end, desc = "Move to Above Split" },
{ "<C-l>", function() require("smart-splits").move_cursor_right() end, desc = "Move to Right Split" },
-- Изменение размера (Alt + hjkl)
{ "<A-h>", function() require("smart-splits").resize_left() end, desc = "Resize Left" },
{ "<A-j>", function() require("smart-splits").resize_down() end, desc = "Resize Down" },
{ "<A-k>", function() require("smart-splits").resize_up() end, desc = "Resize Up" },
{ "<A-l>", function() require("smart-splits").resize_right() end, desc = "Resize Right" },
},
},
}
