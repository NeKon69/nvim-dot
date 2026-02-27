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
require("cmp_nvim_lsp").default_capabilities(p1)
require("cmp_nvim_lsp").setup()
require("cmp_nvim_lsp").update_capabilities(p1, p2)
```

## Harder Calls (quick notes)

- `require("cmp_nvim_lsp").update_capabilities(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("cmp_nvim_lsp").default_capabilities(p1)`: argument contract may be non-obvious; check :help/README.
- `require("cmp_nvim_lsp")._on_insert_enter()`: argument contract may be non-obvious; check :help/README.
- `require("cmp_nvim_lsp").setup()`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help cmp_nvim_lsp` and `:help cmp_nvim_lsp.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/cmp-nvim-lsp/README.md`
- GitHub README: https://github.com/hrsh7th/cmp-nvim-lsp/blob/master/README.md

_Generated in headless mode with forced plugin load._
