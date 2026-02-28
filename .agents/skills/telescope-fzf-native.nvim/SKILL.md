# Telescope-fzf-native.nvim API Reference

This file is generated for plugin `nvim-telescope/telescope-fzf-native.nvim` and module `fzf_lib`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`fzf_lib`)

```lua
require("fzf_lib") -- table
require("fzf_lib").allocate_slab()
require("fzf_lib").free_pattern(p)
require("fzf_lib").free_slab(s)
require("fzf_lib").get_pos(input, pattern_struct, slab)
require("fzf_lib").get_score(input, pattern_struct, slab)
require("fzf_lib").parse_pattern(pattern, case_mode, fuzzy)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help fzf_lib`, the local README, and the GitHub README listed below.

- `require("fzf_lib").get_pos(input, pattern_struct, slab)`
- `require("fzf_lib").get_score(input, pattern_struct, slab)`
- `require("fzf_lib").parse_pattern(pattern, case_mode, fuzzy)`
- `require("fzf_lib").free_pattern(p)`
- `require("fzf_lib").free_slab(s)`
- `require("fzf_lib").allocate_slab()`

## References

- Help: `:help fzf_lib` and `:help fzf_lib.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/telescope-fzf-native.nvim/README.md`
- GitHub README: https://github.com/nvim-telescope/telescope-fzf-native.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
