# Lspsaga.nvim API Reference

This file is generated for plugin `nvimdev/lspsaga.nvim` and module `lspsaga`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:Lspsaga
```

## Module API (`lspsaga`)

```lua
require("lspsaga") -- table
require("lspsaga").saga_augroup -- number
require("lspsaga").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help lspsaga`, the local README, and the GitHub README listed below.

- `require("lspsaga").setup(opts)`

## References

- Help: `:help lspsaga` and `:help lspsaga.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lspsaga.nvim/README.md`
- GitHub README: https://github.com/nvimdev/lspsaga.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
