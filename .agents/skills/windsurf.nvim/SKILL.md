# Windsurf.nvim API Reference

This file is generated for plugin `Exafunction/windsurf.nvim` and module `codeium`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`codeium`)

```lua
require("codeium") -- table
require("codeium").chat()
require("codeium").disable()
require("codeium").enable()
require("codeium").setup(options)
require("codeium").toggle()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help codeium`, the local README, and the GitHub README listed below.

- `require("codeium").setup(options)`
- `require("codeium").chat()`
- `require("codeium").disable()`
- `require("codeium").enable()`
- `require("codeium").toggle()`

## References

- Help: `:help codeium` and `:help codeium.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/windsurf.nvim/README.md`
- GitHub README: https://github.com/Exafunction/windsurf.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
