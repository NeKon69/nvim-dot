# Lazydev.nvim API Reference

This file is generated for plugin `folke/lazydev.nvim` and module `lazydev`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lazydev`)

```lua
require("lazydev") -- table
require("lazydev").find_workspace(buf)
require("lazydev").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help lazydev`, the local README, and the GitHub README listed below.

- `require("lazydev").find_workspace(buf)`
- `require("lazydev").setup(opts)`

## References

- Help: `:help lazydev` and `:help lazydev.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lazydev.nvim/README.md`
- GitHub README: https://github.com/folke/lazydev.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
