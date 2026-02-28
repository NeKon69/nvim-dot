# Cmp-nvim-lsp API Reference

This file is generated for plugin `hrsh7th/cmp-nvim-lsp` and module `cmp_nvim_lsp`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`cmp_nvim_lsp`)

```lua
require("cmp_nvim_lsp") -- table
require("cmp_nvim_lsp")._on_insert_enter()
require("cmp_nvim_lsp").client_source_map -- table
require("cmp_nvim_lsp").default_capabilities(override)
require("cmp_nvim_lsp").setup()
require("cmp_nvim_lsp").update_capabilities(_, override)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help cmp_nvim_lsp`, the local README, and the GitHub README listed below.

- `require("cmp_nvim_lsp").update_capabilities(_, override)`
- `require("cmp_nvim_lsp").default_capabilities(override)`
- `require("cmp_nvim_lsp")._on_insert_enter()`
- `require("cmp_nvim_lsp").setup()`

## References

- Help: `:help cmp_nvim_lsp` and `:help cmp_nvim_lsp.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/cmp-nvim-lsp/README.md`
- GitHub README: https://github.com/hrsh7th/cmp-nvim-lsp/blob/master/README.md

_Generated in headless mode with forced plugin load._
