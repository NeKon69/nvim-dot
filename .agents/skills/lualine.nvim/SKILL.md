# Lualine.nvim API Reference

This file is generated for plugin `nvim-lualine/lualine.nvim` and module `lualine`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lualine`)

```lua
require("lualine") -- table
require("lualine").get_config()
require("lualine").hide(opts)
require("lualine").refresh(opts)
require("lualine").setup(user_config)
require("lualine").statusline(focused)
require("lualine").tabline()
require("lualine").winbar(focused)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help lualine`, the local README, and the GitHub README listed below.

- `require("lualine").hide(opts)`
- `require("lualine").refresh(opts)`
- `require("lualine").setup(user_config)`
- `require("lualine").statusline(focused)`
- `require("lualine").winbar(focused)`
- `require("lualine").get_config()`
- `require("lualine").tabline()`

## References

- Help: `:help lualine` and `:help lualine.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lualine.nvim/README.md`
- GitHub README: https://github.com/nvim-lualine/lualine.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
