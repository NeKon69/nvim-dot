# Plugin.lua.plugins.gitsigns API Reference

This file is generated for source `lua/plugins/gitsigns.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.gitsigns`)

```lua
vim.keymap.set("n", "<leader>gb", gs.blame_line, { desc = "Blame Line" })

vim.keymap.set("n", "<leader>gp", gs.preview_hunk, { desc = "Preview Hunk" })

vim.keymap.set("n", "<leader>gr", gs.reset_hunk, { desc = "Reset Hunk" })

vim.keymap.set("n", "<leader>gs", gs.stage_hunk, { desc = "Stage Hunk" })

vim.keymap.set("n", "<leader>gt", gs.toggle_current_line_blame, { desc = "Toggle Blame" })

vim.keymap.set("n", "[c", function()

vim.keymap.set("n", "]c", function()

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `gitsigns` (skill: `skills/gitsigns.nvim/SKILL.md`)

- `lewis6991/gitsigns.nvim` (skill: `skills/gitsigns.nvim/SKILL.md`)


_Generated in headless mode from static file analysis._
