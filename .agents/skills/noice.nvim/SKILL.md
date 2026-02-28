# Noice.nvim API Reference

This file is generated for plugin `folke/noice.nvim` and module `noice`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`noice`)

```lua
require("noice") -- table
require("noice").api -- table
require("noice").cmd(name)
require("noice").deactivate()
require("noice").disable()
require("noice").enable()
require("noice").notify(msg, level, opts)
require("noice").redirect(cmd, routes)
require("noice").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help noice`, the local README, and the GitHub README listed below.

- `require("noice").notify(msg, level, opts)`
- `require("noice").redirect(cmd, routes)`
- `require("noice").cmd(name)`
- `require("noice").setup(opts)`
- `require("noice").deactivate()`
- `require("noice").disable()`
- `require("noice").enable()`

## References

- Help: `:help noice` and `:help noice.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/noice.nvim/README.md`
- GitHub README: https://github.com/folke/noice.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
