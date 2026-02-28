# Rainbow-delimiters.nvim API Reference

This file is generated for plugin `HiPhish/rainbow-delimiters.nvim` and module `rainbow-delimiters`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`rainbow-delimiters`)

```lua
require("rainbow-delimiters") -- table
require("rainbow-delimiters").disable(bufnr)
require("rainbow-delimiters").enable(bufnr)
require("rainbow-delimiters").hlgroup_at(i)
require("rainbow-delimiters").is_enabled(bufnr)
require("rainbow-delimiters").strategy -- table
require("rainbow-delimiters").strategy.global -- string
require("rainbow-delimiters").strategy.local -- string
require("rainbow-delimiters").strategy.noop -- string
require("rainbow-delimiters").toggle(bufnr)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help rainbow-delimiters`, the local README, and the GitHub README listed below.

- `require("rainbow-delimiters").disable(bufnr)`
- `require("rainbow-delimiters").enable(bufnr)`
- `require("rainbow-delimiters").hlgroup_at(i)`
- `require("rainbow-delimiters").is_enabled(bufnr)`
- `require("rainbow-delimiters").toggle(bufnr)`

## References

- Help: `:help rainbow-delimiters` and `:help rainbow-delimiters.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/rainbow-delimiters.nvim/README.md`
- GitHub README: https://github.com/HiPhish/rainbow-delimiters.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
