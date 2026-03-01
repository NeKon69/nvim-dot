# Wrapped.nvim API Reference

This file is generated for plugin `aikhe/wrapped.nvim` and module `wrapped`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:NvimWrapped
:WrappedNvim
```

## Module API (`wrapped`)

```lua
require("wrapped") -- table
require("wrapped").run()
require("wrapped").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help wrapped`, the local README, and the GitHub README listed below.

- `require("wrapped").setup(opts)`
- `require("wrapped").run()`

## References

- Help: `:help wrapped` and `:help wrapped.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/wrapped.nvim/README.md`
- GitHub README: https://github.com/aikhe/wrapped.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
