# Plugin.lua.plugins.substitute API Reference

This file is generated for source `lua/plugins/substitute.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.substitute`)

```lua
vim.keymap.set(

vim.keymap.set("n", "gr", substitute.operator, { desc = "Substitute", nowait = true })

vim.keymap.set("n", "grr", substitute.line, { desc = "Substitute Line", nowait = true })

vim.keymap.set("n", "gx", require("substitute.exchange").operator, { desc = "Exchange", nowait = true })

vim.keymap.set("n", "gxx", require("substitute.exchange").line, { desc = "Exchange Line", nowait = true })

vim.keymap.set("x", "gr", substitute.visual, { desc = "Substitute Selection", nowait = true })

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `gbprod/substitute.nvim` (skill: `skills/substitute.nvim/SKILL.md`)

- `substitute` (skill: `skills/substitute.nvim/SKILL.md`)

- `substitute.exchange`


_Generated in headless mode from static file analysis._
