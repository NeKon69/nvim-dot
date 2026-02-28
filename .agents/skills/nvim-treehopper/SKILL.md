# Nvim-treehopper API Reference

This file is generated for plugin `mfussenegger/nvim-treehopper` and module `tsht`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`tsht`)

```lua
require("tsht") -- table
require("tsht").config -- table
require("tsht").config.hint_keys -- table
require("tsht").move(opts)
require("tsht").nodes(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help tsht`, the local README, and the GitHub README listed below.

- `require("tsht").move(opts)`
- `require("tsht").nodes(opts)`

## References

- Help: `:help tsht` and `:help tsht.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-treehopper/README.md`
- GitHub README: https://github.com/mfussenegger/nvim-treehopper/blob/master/README.md

_Generated in headless mode with forced plugin load._
