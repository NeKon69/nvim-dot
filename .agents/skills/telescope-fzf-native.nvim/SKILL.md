# Telescope-fzf-native.nvim API Reference

This file is generated for plugin `nvim-telescope/telescope-fzf-native.nvim` and module `fzf_lib`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`fzf_lib`)

```lua
require("fzf_lib") -- table
require("fzf_lib").allocate_slab()
require("fzf_lib").free_pattern(p1)
require("fzf_lib").free_slab(p1)
require("fzf_lib").get_pos(p1, p2, p3)
require("fzf_lib").get_score(p1, p2, p3)
require("fzf_lib").parse_pattern(p1, p2, p3)
```

## Harder Calls (quick notes)

- `require("fzf_lib").get_pos(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("fzf_lib").get_score(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("fzf_lib").parse_pattern(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("fzf_lib").free_pattern(p1)`: argument contract may be non-obvious; check :help/README.
- `require("fzf_lib").free_slab(p1)`: argument contract may be non-obvious; check :help/README.
- `require("fzf_lib").allocate_slab()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help fzf_lib` and `:help fzf_lib.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/telescope-fzf-native.nvim/README.md`
- GitHub README: https://github.com/nvim-telescope/telescope-fzf-native.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
