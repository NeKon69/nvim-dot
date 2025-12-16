local map = vim.keymap.set

-- [[ Find ]] -----------------------------------------------------------------

map("n", "<leader>f", "", { noremap = true, silent = true, desc = "󰗨 Find" })
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "Find Files" })
map("n", "<leader>fs", function()
	local ok, picker = pcall(require, "plugins.telescope")
	if ok and picker.smart_file_picker then
		picker.smart_file_picker()
	end
end, { desc = "Find Smart (History)" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "Grep (Find Text)" })
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = "Find Buffers" })
map("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end, { desc = "Find Old Files" })
map({ "n", "t" }, "<leader>ft", function()
	require("snacks").terminal()
end, { desc = "Float Terminal" })

-- [[ Project & Files ]] ------------------------------------------------------
map("n", "<leader>p", "", { noremap = true, silent = true, desc = "󰓃 Project" })
map("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle({ find_file = true, float = true })
end, { desc = "Toggle File Explorer" })
map("n", "<leader>pn", function()
	require("user.templates").create_from_template()
end, { desc = "New from Template" })

-- [[ Harpoon ]] --------------------------------------------------------------
-- This is a placeholder for Harpoon, which we will configure next.
map("n", "<leader>h", "", { noremap = true, silent = true, desc = "󱡀 Harpoon" })
map("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, { desc = "Add File to Harpoon" })
map("n", "<leader>hh", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Toggle Harpoon Menu" })

local function open_in_split(split_type)
	local builtin = require("telescope.builtin")
	local actions = require("telescope.actions")
	local action = split_type == "v" and actions.select_vertical or actions.select_horizontal
	builtin.find_files({
		attach_mappings = function(prompt_bufnr, map_fn)
			map_fn("i", "<CR>", action)
			map_fn("n", "<CR>", action)
			return true
		end,
	})
end
map("n", "<leader>s", "", { noremap = true, silent = true, desc = "󰙑 Split" })
map("n", "<leader>sv", function()
	open_in_split("v")
end, { desc = "Split Vertical" })
map("n", "<leader>sh", function()
	open_in_split("h")
end, { desc = "Split Horizontal" })
map("n", "<leader>se", "<C-w>=", { desc = "Split Equal" })
map("n", "<leader>sx", ":close<CR>", { desc = "Split Close" })

-- [[ Git ]] ------------------------------------------------------------------
map("n", "<leader>g", "", { noremap = true, silent = true, desc = "󰊢 Git" })
map("n", "<leader>gg", "<cmd>LazyGit<CR>", { desc = "LazyGit" })
map("n", "<leader>gs", function()
	require("gitsigns").stage_hunk()
end, { desc = "Stage Hunk" })
map("n", "<leader>gr", function()
	require("gitsigns").reset_hunk()
end, { desc = "Reset Hunk" })
map("n", "<leader>gp", function()
	require("gitsigns").preview_hunk()
end, { desc = "Preview Hunk" })
map("n", "<leader>gb", function()
	require("gitsigns").blame_line()
end, { desc = "Blame Line" })
map("n", "]c", function()
	require("gitsigns").next_hunk()
end, { desc = "Next Hunk" })
map("n", "[c", function()
	require("gitsigns").prev_hunk()
end, { desc = "Previous Hunk" })

-- [[ Code ]] -----------------------------------------------------------------
map("n", "<leader>c", "", { noremap = true, silent = true, desc = "󰘦 Code" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cf", vim.lsp.buf.format, { desc = "Format Code" })
map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename Symbol" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
map("n", "gi", vim.lsp.buf.implementation, { desc = "Go to Implementation" })
map("n", "gr", function()
	require("telescope.builtin").lsp_references()
end, { desc = "Find References" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover Documentation" })

-- [[ Diagnostics ]] ----------------------------------------------------------
map("n", "<leader>x", "", { noremap = true, silent = true, desc = "󰅙 Diagnostics" })
map("n", "<leader>xx", function()
	require("trouble").toggle()
end, { desc = "Toggle Trouble" })
map("n", "<leader>xw", function()
	require("trouble").toggle("workspace_diagnostics")
end, { desc = "Workspace Diagnostics" })
map("n", "<leader>xd", function()
	require("trouble").toggle("document_diagnostics")
end, { desc = "Document Diagnostics" })
map("n", "gl", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Previous Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })

-- [[ Debug ]] ----------------------------------------------------------------
map("n", "<leader>d", "", { noremap = true, silent = true, desc = "󰃤 Debug" })
-- This group is a placeholder for the Debug Hydra we will create later.

map("n", "<leader>u", "", { noremap = true, silent = true, desc = "󰙵 UI Toggles" })

map("n", "<leader>q", "", { noremap = true, silent = true, desc = "󰍃 Quit" })
map("n", "<leader>qq", ":qa!<CR>", { desc = "Quit Neovim" })

map("n", "<C-h>", "<C-w>h", { desc = "Navigate Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate Right" })
