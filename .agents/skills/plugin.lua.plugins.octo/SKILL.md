# Plugin.lua.plugins.octo API Reference

This file is generated for source `lua/plugins/octo.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.octo`)

```lua
vim.keymap.set("i", "#", "#<C-x><C-o>", { silent = true, buffer = true })

vim.keymap.set("i", "@", "@<C-x><C-o>", { silent = true, buffer = true })

event = "FileType"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `nvim-lua/plenary.nvim` (skill: `skills/plenary.nvim/SKILL.md`)

- `nvim-telescope/telescope.nvim` (skill: `skills/telescope.nvim/SKILL.md`)

- `nvim-tree/nvim-web-devicons` (skill: `skills/nvim-web-devicons/SKILL.md`)

- `octo` (skill: `skills/octo.nvim/SKILL.md`)

- `pwntester/octo.nvim` (skill: `skills/octo.nvim/SKILL.md`)


_Generated in headless mode from static file analysis._
