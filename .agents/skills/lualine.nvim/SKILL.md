# Lualine.nvim API Reference

This file is generated for plugin `nvim-lualine/lualine.nvim` and module `lualine`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lualine`)

```lua
require("lualine") -- table
require("lualine").get_config()
require("lualine").hide(p1)
require("lualine").refresh(p1)
require("lualine").setup(p1)
require("lualine").statusline(p1)
require("lualine").tabline()
require("lualine").winbar(p1)
```

## Harder Calls (quick notes)

- `require("lualine").hide(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lualine").refresh(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lualine").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("lualine").statusline(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lualine").winbar(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lualine").get_config()`: setup entrypoint; call once and keep opts explicit.
- `require("lualine").tabline()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help lualine` and `:help lualine.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lualine.nvim/README.md`
- GitHub README: https://github.com/nvim-lualine/lualine.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
