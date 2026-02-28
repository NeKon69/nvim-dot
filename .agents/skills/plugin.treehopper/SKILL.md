# Plugin.treehopper API Reference

This file is generated for source `lua/plugins/treehopper.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.treehopper`)

```lua
vim.keymap.set("n", "gM", function()

vim.keymap.set("n", "gm", function()

vim.keymap.set("n", "m", tsht.nodes, { desc = "Select Node (Visual)" })

vim.keymap.set("x", "m", tsht.nodes)

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `mfussenegger/nvim-treehopper` (skill: `.agents/skills/nvim-treehopper/SKILL.md`)

- `nvim-treesitter/nvim-treesitter` (skill: `.agents/skills/nvim-treesitter/SKILL.md`)

- `tsht`


_Generated in headless mode from static file analysis._
