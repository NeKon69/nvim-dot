# Peek.nvim API Reference

This file is generated for plugin `toppair/peek.nvim` and module `peek`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`peek`)

```lua
require("peek") -- table
require("peek").close(...)
require("peek").is_open(...)
require("peek").open(...)
require("peek").setup(cfg)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help peek`, the local README, and the GitHub README listed below.

- `require("peek").setup(cfg)`
- `require("peek").close(...)`
- `require("peek").is_open(...)`
- `require("peek").open(...)`

## References

- Help: `:help peek` and `:help peek.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/peek.nvim/README.md`
- GitHub README: https://github.com/toppair/peek.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
