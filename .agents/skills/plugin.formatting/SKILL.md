# Plugin.formatting API Reference

This file is generated for source `lua/plugins/formatting.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.formatting`)

```lua
vim.keymap.set("n", "<leader>cl", function()

event = "BufEnter"

event = "BufWritePost"

event = "InsertLeave"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `conform` (skill: `.agents/skills/conform.nvim/SKILL.md`)

- `lint`

- `mfussenegger/nvim-lint` (skill: `.agents/skills/nvim-lint/SKILL.md`)

- `stevearc/conform.nvim` (skill: `.agents/skills/conform.nvim/SKILL.md`)


_Generated in headless mode from static file analysis._
