# Nvim-treesitter-context API Reference

This file is generated for plugin `nvim-treesitter/nvim-treesitter-context` and module `treesitter-context`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:TSContext
```

## Module API (`treesitter-context`)

```lua
require("treesitter-context") -- table
require("treesitter-context").config -- table
require("treesitter-context").config.update(cfg)
require("treesitter-context").disable()
require("treesitter-context").enable()
require("treesitter-context").enabled()
require("treesitter-context").go_to_context(depth)
require("treesitter-context").setup(options)
require("treesitter-context").toggle()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help treesitter-context`, the local README, and the GitHub README listed below.

- `require("treesitter-context").config.update(cfg)`
- `require("treesitter-context").go_to_context(depth)`
- `require("treesitter-context").setup(options)`
- `require("treesitter-context").disable()`
- `require("treesitter-context").enable()`
- `require("treesitter-context").enabled()`
- `require("treesitter-context").toggle()`

## References

- Help: `:help treesitter-context` and `:help treesitter-context.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-treesitter-context/README.md`
- GitHub README: https://github.com/nvim-treesitter/nvim-treesitter-context/blob/master/README.md

_Generated in headless mode with forced plugin load._
