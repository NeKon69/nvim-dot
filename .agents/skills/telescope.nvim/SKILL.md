# Telescope.nvim API Reference

This file is generated for plugin `nvim-telescope/telescope.nvim` and module `telescope`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:Telescope
```

## Module API (`telescope`)

```lua
require("telescope") -- table
require("telescope").__format_setup_keys()
require("telescope").extensions -- table
require("telescope").load_extension(name)
require("telescope").register_extension(mod)
require("telescope").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help telescope`, the local README, and the GitHub README listed below.

- `require("telescope").load_extension(name)`
- `require("telescope").register_extension(mod)`
- `require("telescope").setup(opts)`
- `require("telescope").__format_setup_keys()`

## References

- Help: `:help telescope` and `:help telescope.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/telescope.nvim/README.md`
- GitHub README: https://github.com/nvim-telescope/telescope.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
