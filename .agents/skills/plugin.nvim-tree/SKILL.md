# Plugin.nvim-tree API Reference

This file is generated for source `lua/plugins/nvim-tree.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.nvim-tree`)

```lua
vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("⬆️  Up Directory"))

vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("⬅️  Prev Sibling"))

vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))

vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))

vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("💿 CD"))

vim.keymap.set("n", "<C-f>", telescope_find_directory, opts("🔭🗂️  Telescope: Find Directory"))

vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("ℹ️  Info"))

vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("✏️  Rename: Omit Filename"))

vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))

vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("👁️  Preview"))

vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("➡️  Next Sibling"))

vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("🗂️  Toggle No Buffer"))

vim.keymap.set("n", "D", api.fs.trash, opts("🗑️  Trash"))

vim.keymap.set("n", "E", api.tree.expand_all, opts("📂 Expand All"))

vim.keymap.set("n", "F", telescope_live_grep, opts("🔭 Telescope: Live Grep"))

vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("👁️  Toggle Dotfiles"))

vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("🔀 Toggle Git Ignore"))

vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("⬇️  Last Sibling"))

vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("⬆️  First Sibling"))

vim.keymap.set("n", "R", api.tree.reload, opts("🔄 Refresh"))

vim.keymap.set("n", "S", api.tree.search_node, opts("🔍 Search Node"))

vim.keymap.set("n", "W", api.tree.collapse_all, opts("📁 Collapse All"))

vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("📋 Copy Relative Path"))

vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("⬅️  Prev Git"))

vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("⬅️  Prev Diagnostic"))

vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("➡️  Next Git"))

vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("➡️  Next Diagnostic"))

vim.keymap.set("n", "a", api.fs.create, opts("➕ Create File/Directory"))

vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("🗑️  Delete Bookmarked"))

vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("📦 Move Bookmarked"))

vim.keymap.set("n", "bt", api.marks.bulk.trash, opts("🗑️  Trash Bookmarked"))

vim.keymap.set("n", "c", api.fs.copy.node, opts("📋 Copy"))

vim.keymap.set("n", "d", api.fs.remove, opts("🗑️  Delete"))

vim.keymap.set("n", "e", api.fs.rename_basename, opts("✏️  Rename: Basename"))

vim.keymap.set("n", "f", telescope_find_files, opts("🔭 Telescope: Find Files"))

vim.keymap.set("n", "g?", api.tree.toggle_help, opts("❓ Help"))

vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("📋 Copy Absolute Path"))

vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))

vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))

vim.keymap.set("n", "m", api.marks.toggle, opts("🔖 Toggle Bookmark"))

vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))

vim.keymap.set("n", "p", api.fs.paste, opts("📌 Paste"))

vim.keymap.set("n", "q", api.tree.close, opts("❌ Close"))

vim.keymap.set("n", "r", api.fs.rename, opts("✏️  Rename"))

vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))

vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))

vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))

vim.keymap.set("n", "x", api.fs.cut, opts("✂️  Cut"))

vim.keymap.set("n", "y", api.fs.copy.filename, opts("📋 Copy Name"))

event = "FileType"

event = "VimEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `nvim-tree`

- `nvim-tree.api`

- `nvim-tree/nvim-tree.lua` (skill: `.agents/skills/nvim-tree.lua/SKILL.md`)

- `nvim-tree/nvim-web-devicons` (skill: `.agents/skills/nvim-web-devicons/SKILL.md`)

- `telescope.actions`

- `telescope.actions.state`

- `telescope.builtin`

- `telescope.config`

- `telescope.finders`

- `telescope.pickers`


_Generated in headless mode from static file analysis._
