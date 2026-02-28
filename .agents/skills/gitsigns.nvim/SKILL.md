# Gitsigns.nvim API Reference

This file is generated for plugin `lewis6991/gitsigns.nvim` and module `gitsigns`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:Gitsigns
```

## Module API (`gitsigns`)

```lua
require("gitsigns") -- table
require("gitsigns").setup(cfg)
require("gitsigns").statuscolumn(bufnr, lnum)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help gitsigns`, the local README, and the GitHub README listed below.

- `require("gitsigns").statuscolumn(bufnr, lnum)`
- `require("gitsigns").setup(cfg)`

## References

- Help: `:help gitsigns` and `:help gitsigns.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/gitsigns.nvim/README.md`
- GitHub README: https://github.com/lewis6991/gitsigns.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
