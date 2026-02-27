# Noice.nvim API Reference

This file is generated for plugin `folke/noice.nvim` and module `noice`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`noice`)

```lua
require("noice") -- table
require("noice").api -- table
require("noice").cmd(p1)
require("noice").deactivate()
require("noice").disable()
require("noice").enable()
require("noice").notify(p1, p2, p3)
require("noice").redirect(p1, p2)
require("noice").setup(p1)
```

## Harder Calls (quick notes)

- `require("noice").notify(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("noice").redirect(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("noice").cmd(p1)`: argument contract may be non-obvious; check :help/README.
- `require("noice").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("noice").deactivate()`: argument contract may be non-obvious; check :help/README.
- `require("noice").disable()`: argument contract may be non-obvious; check :help/README.
- `require("noice").enable()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help noice` and `:help noice.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/noice.nvim/README.md`
- GitHub README: https://github.com/folke/noice.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
