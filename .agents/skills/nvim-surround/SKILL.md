# Nvim-surround API Reference

This file is generated for plugin `kylechui/nvim-surround` and module `nvim-surround`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`nvim-surround`)

```lua
require("nvim-surround") -- table
require("nvim-surround").buffer_setup(p1)
require("nvim-surround").change_callback()
require("nvim-surround").change_surround(p1)
require("nvim-surround").delete_callback()
require("nvim-surround").delete_surround(p1)
require("nvim-surround").insert_surround(p1)
require("nvim-surround").normal_callback(p1)
require("nvim-surround").normal_surround(p1)
require("nvim-surround").pending_surround -- boolean
require("nvim-surround").setup(p1)
require("nvim-surround").visual_surround(p1)
```

## Harder Calls (quick notes)

- `require("nvim-surround").buffer_setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("nvim-surround").change_surround(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-surround").delete_surround(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-surround").insert_surround(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-surround").normal_callback(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-surround").normal_surround(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-surround").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("nvim-surround").visual_surround(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help nvim-surround` and `:help nvim-surround.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-surround/README.md`
- GitHub README: https://github.com/kylechui/nvim-surround/blob/master/README.md

_Generated in headless mode with forced plugin load._
