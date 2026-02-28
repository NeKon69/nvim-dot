# Plugin.lua.plugins.build-system API Reference

This file is generated for source `lua/plugins/build-system.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:DebugTargetEdit

:DebugTargetShow

:ProfileRemove

:TargetRemove

:TargetWizard

```

## Module API (`plugins.build-system`)

```lua
vim.keymap.set("i", "<CR>", function()

vim.keymap.set("n", "<CR>", function()

vim.keymap.set("n", "<CR>", run_current_line, {

vim.keymap.set("n", "<leader>bE", function()

vim.keymap.set("n", "<leader>bP", function()

vim.keymap.set("n", "<leader>bR", remove_target_wizard, { desc = "🗑️ Remove Target" })

vim.keymap.set("n", "<leader>bT", function()

vim.keymap.set("n", "<leader>bX", quick_run_interactive, { desc = "🚀 Quick Run (Term)" })

vim.keymap.set("n", "<leader>ba", target_wizard, { desc = "🎯 Target Wizard" })

vim.keymap.set("n", "<leader>bb", function()

vim.keymap.set("n", "<leader>bc", function()

vim.keymap.set("n", "<leader>be", open_args_console, { desc = "Args Console (Run on Enter)" })

vim.keymap.set("n", "<leader>bp", remove_profile_wizard, { desc = "🗑️ Remove Profile" })

vim.keymap.set("n", "<leader>br", function()

vim.keymap.set("n", "<leader>bt", function()

vim.keymap.set("n", "<leader>bx", quick_run_interactive, { desc = "🚀 Quick Run (Term)" })

vim.keymap.set("n", "q", function()

vim.keymap.set("t", "<C-p>", function()

vim.keymap.set({ "n", "i" }, "<C-t>", function()

event = "BufWriteCmd"

event = "BufWritePost"

event = "DirChanged"

event = "VimEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `.nvim/debug_targets.json`

- `lualine` (skill: `skills/lualine.nvim/SKILL.md`)

- `overseer` (skill: `skills/overseer.nvim/SKILL.md`)

- `stevearc/overseer.nvim` (skill: `skills/overseer.nvim/SKILL.md`)

- `telescope.actions`

- `telescope.actions.state`

- `toggleterm` (skill: `skills/toggleterm.nvim/SKILL.md`)


_Generated in headless mode from static file analysis._
