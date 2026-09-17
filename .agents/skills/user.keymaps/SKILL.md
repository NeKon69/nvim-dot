# User.keymaps API Reference

This file is generated for source `lua/user/keymaps.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`user.keymaps`)

```lua
vim.keymap.set("n", "<M-q>", function()

vim.keymap.set("n", "<M-w>", function()

vim.keymap.set("n", "<leader>ph", history.list_history, { desc = "📜 Project History" })

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `harpoon`

- `nvim-tree.api`

- `telescope.actions`

- `telescope.builtin`

- `trouble` (skill: `.agents/skills/trouble.nvim/SKILL.md`)


_Generated in headless mode from static file analysis._
