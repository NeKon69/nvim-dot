local map = vim.keymap.set

-- [[ Find ]] -----------------------------------------------------------------

map("n", "<leader>f", "", { noremap = true, silent = true, desc = "🔍 Find / Search" })
map("n", "<leader>ff", function()
	require("telescope.builtin").find_files()
end, { desc = "🔭 Find Files" })
map("n", "<leader>fs", function()
	require("telescope.builtin").oldfiles({
		only_cwd = true,
		prompt_title = "Recent Files (Project)",
	})
end, { desc = "↺ Recent (Project)" })
map("n", "<leader>fg", function()
	require("telescope.builtin").live_grep()
end, { desc = "⚡ Live Grep" })
map("n", "<leader>fb", function()
	require("telescope.builtin").buffers()
end, { desc = " Buffers" })
map("n", "<leader>fo", function()
	require("telescope.builtin").oldfiles()
end, { desc = "🌍 Recent (Global)" })
map({ "n", "t" }, "<leader>ft", function()
	require("snacks").terminal()
end, { desc = " Float Terminal" })

-- [[ Project & Files ]] ------------------------------------------------------
map("n", "<leader>p", "", { noremap = true, silent = true, desc = "󰓃 Project" })
map("n", "<leader>e", function()
	require("nvim-tree.api").tree.toggle({ find_file = true, float = true })
end, { desc = "Toggle File Explorer" })
map("n", "<leader>pn", function()
	require("user.templates").create_from_template()
end, { desc = "New from Template" })

-- [[ Harpoon ]] --------------------------------------------------------------
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

-- [[ Code ]] -----------------------------------------------------------------
map("n", "<leader>c", "", { noremap = true, silent = true, desc = "󰘦 Code" })
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

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

map("n", "<leader>u", "", { noremap = true, silent = true, desc = "󰙵 UI Toggles" })

map("n", "<leader>q", "", { noremap = true, silent = true, desc = "󰍃 Quit" })
map("n", "<leader>qq", ":qa!<CR>", { desc = "Quit Neovim" })

map("n", "<C-h>", "<C-w>h", { desc = "Navigate Left" })
map("n", "<C-j>", "<C-w>j", { desc = "Navigate Down" })
map("n", "<C-k>", "<C-w>k", { desc = "Navigate Up" })
map("n", "<C-l>", "<C-w>l", { desc = "Navigate Right" })

-- [[ Build System (Overseer) ]] -----------------------------------------------
map("n", "<leader>b", "", { noremap = true, silent = true, desc = "󱓧 Build" })

map("n", "<leader>bb", "<cmd>Telescope overseer<CR>", { desc = "Build: Run Task" })
map("n", "<leader>br", "<cmd>OverseerRunLast<CR>", { desc = "Build: Run Last" })
map("n", "<leader>bs", "<cmd>OverseerTaskAction stop<CR>", { desc = "Build: Stop" })
map("n", "<leader>bo", "<cmd>OverseerToggle<CR>", { desc = "Build: Toggle Panel" })
