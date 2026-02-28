# Git-conflict.nvim API Reference

This file is generated for plugin `akinsho/git-conflict.nvim` and module `git-conflict`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`git-conflict`)

```lua
require("git-conflict") -- table
require("git-conflict").choose(side)
require("git-conflict").clear(bufnr)
require("git-conflict").conflict_count(bufnr)
require("git-conflict").conflicts_to_qf_items(callback)
require("git-conflict").debug_watchers()
require("git-conflict").find_next(side)
require("git-conflict").find_prev(side)
require("git-conflict").setup(user_config)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help git-conflict`, the local README, and the GitHub README listed below.

- `require("git-conflict").choose(side)`
- `require("git-conflict").clear(bufnr)`
- `require("git-conflict").conflict_count(bufnr)`
- `require("git-conflict").conflicts_to_qf_items(callback)`
- `require("git-conflict").find_next(side)`
- `require("git-conflict").find_prev(side)`
- `require("git-conflict").setup(user_config)`
- `require("git-conflict").debug_watchers()`

## References

- Help: `:help git-conflict` and `:help git-conflict.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/git-conflict.nvim/README.md`
- GitHub README: https://github.com/akinsho/git-conflict.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
