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
require("gitsigns").setup(p1)
require("gitsigns").statuscolumn(p1, p2)
```

## Harder Calls (quick notes)

- `require("gitsigns").statuscolumn(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("gitsigns").setup(p1)`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help gitsigns` and `:help gitsigns.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/gitsigns.nvim/README.md`
- GitHub README: https://github.com/lewis6991/gitsigns.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
