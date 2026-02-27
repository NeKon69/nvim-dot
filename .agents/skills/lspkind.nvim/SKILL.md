# Lspkind.nvim API Reference

This file is generated for plugin `onsails/lspkind.nvim` and module `lspkind`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lspkind`)

```lua
require("lspkind") -- table
require("lspkind").cmp_format(p1)
require("lspkind").init(p1)
require("lspkind").presets -- table
require("lspkind").presets.codicons -- table
require("lspkind").presets.codicons.Class -- string
require("lspkind").presets.codicons.Color -- string
require("lspkind").presets.codicons.Constant -- string
require("lspkind").presets.codicons.Constructor -- string
require("lspkind").presets.codicons.Enum -- string
require("lspkind").presets.codicons.EnumMember -- string
require("lspkind").presets.codicons.Event -- string
require("lspkind").presets.codicons.Field -- string
require("lspkind").presets.codicons.File -- string
require("lspkind").presets.codicons.Folder -- string
require("lspkind").presets.codicons.Function -- string
require("lspkind").presets.codicons.Interface -- string
require("lspkind").presets.codicons.Keyword -- string
require("lspkind").presets.codicons.Method -- string
require("lspkind").presets.codicons.Module -- string
require("lspkind").presets.codicons.Operator -- string
require("lspkind").presets.codicons.Property -- string
require("lspkind").presets.codicons.Reference -- string
require("lspkind").presets.codicons.Snippet -- string
require("lspkind").presets.codicons.Struct -- string
require("lspkind").presets.codicons.Text -- string
require("lspkind").presets.codicons.TypeParameter -- string
require("lspkind").presets.codicons.Unit -- string
require("lspkind").presets.codicons.Value -- string
require("lspkind").presets.codicons.Variable -- string
require("lspkind").presets.default -- table
require("lspkind").presets.default.Class -- string
require("lspkind").presets.default.Color -- string
require("lspkind").presets.default.Constant -- string
require("lspkind").presets.default.Constructor -- string
require("lspkind").presets.default.Enum -- string
require("lspkind").presets.default.EnumMember -- string
require("lspkind").presets.default.Event -- string
require("lspkind").presets.default.Field -- string
require("lspkind").presets.default.File -- string
require("lspkind").presets.default.Folder -- string
require("lspkind").presets.default.Function -- string
require("lspkind").presets.default.Interface -- string
require("lspkind").presets.default.Keyword -- string
require("lspkind").presets.default.Method -- string
require("lspkind").presets.default.Module -- string
require("lspkind").presets.default.Operator -- string
require("lspkind").presets.default.Property -- string
require("lspkind").presets.default.Reference -- string
require("lspkind").presets.default.Snippet -- string
require("lspkind").presets.default.Struct -- string
require("lspkind").presets.default.Text -- string
require("lspkind").presets.default.TypeParameter -- string
require("lspkind").presets.default.Unit -- string
require("lspkind").presets.default.Value -- string
require("lspkind").presets.default.Variable -- string
require("lspkind").setup(p1)
require("lspkind").symbolic(p1)
```

## Harder Calls (quick notes)

- `require("lspkind").cmp_format(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lspkind").init(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("lspkind").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("lspkind").symbolic(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help lspkind` and `:help lspkind.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lspkind.nvim/README.md`
- GitHub README: https://github.com/onsails/lspkind.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
