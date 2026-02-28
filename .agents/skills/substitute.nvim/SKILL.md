# Substitute.nvim API Reference

This file is generated for plugin `gbprod/substitute.nvim` and module `substitute`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`substitute`)

```lua
require("substitute") -- table
require("substitute").eol(options)
require("substitute").highlight_substituted_text(marks)
require("substitute").line(options)
require("substitute").operator(options)
require("substitute").operator_callback(vmode)
require("substitute").setup(options)
require("substitute").state -- table
require("substitute").visual(options)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help substitute`, the local README, and the GitHub README listed below.

- `require("substitute").eol(options)`
- `require("substitute").highlight_substituted_text(marks)`
- `require("substitute").line(options)`
- `require("substitute").operator(options)`
- `require("substitute").operator_callback(vmode)`
- `require("substitute").setup(options)`
- `require("substitute").visual(options)`

## References

- Help: `:help substitute` and `:help substitute.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/substitute.nvim/README.md`
- GitHub README: https://github.com/gbprod/substitute.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
