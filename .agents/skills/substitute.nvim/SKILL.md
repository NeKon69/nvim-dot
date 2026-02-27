# Substitute.nvim API Reference

This file is generated for plugin `gbprod/substitute.nvim` and module `substitute`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`substitute`)

```lua
require("substitute") -- table
require("substitute").eol(p1)
require("substitute").highlight_substituted_text(p1)
require("substitute").line(p1)
require("substitute").operator(p1)
require("substitute").operator_callback(p1)
require("substitute").setup(p1)
require("substitute").state -- table
require("substitute").visual(p1)
```

## Harder Calls (quick notes)

- `require("substitute").eol(p1)`: argument contract may be non-obvious; check :help/README.
- `require("substitute").highlight_substituted_text(p1)`: argument contract may be non-obvious; check :help/README.
- `require("substitute").line(p1)`: argument contract may be non-obvious; check :help/README.
- `require("substitute").operator(p1)`: argument contract may be non-obvious; check :help/README.
- `require("substitute").operator_callback(p1)`: argument contract may be non-obvious; check :help/README.
- `require("substitute").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("substitute").visual(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help substitute` and `:help substitute.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/substitute.nvim/README.md`
- GitHub README: https://github.com/gbprod/substitute.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
