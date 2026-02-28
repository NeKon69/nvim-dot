# Nvim-surround API Reference

This file is generated for plugin `kylechui/nvim-surround` and module `nvim-surround`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`nvim-surround`)

```lua
require("nvim-surround") -- table
require("nvim-surround").buffer_setup(buffer_opts)
require("nvim-surround").change_callback()
require("nvim-surround").change_surround(args)
require("nvim-surround").delete_callback()
require("nvim-surround").delete_surround(args)
require("nvim-surround").insert_surround(args)
require("nvim-surround").normal_callback(mode)
require("nvim-surround").normal_surround(args)
require("nvim-surround").pending_surround -- boolean
require("nvim-surround").setup(user_opts)
require("nvim-surround").visual_surround(args)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help nvim-surround`, the local README, and the GitHub README listed below.

- `require("nvim-surround").buffer_setup(buffer_opts)`
- `require("nvim-surround").change_surround(args)`
- `require("nvim-surround").delete_surround(args)`
- `require("nvim-surround").insert_surround(args)`
- `require("nvim-surround").normal_callback(mode)`
- `require("nvim-surround").normal_surround(args)`
- `require("nvim-surround").setup(user_opts)`
- `require("nvim-surround").visual_surround(args)`

## References

- Help: `:help nvim-surround` and `:help nvim-surround.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-surround/README.md`
- GitHub README: https://github.com/kylechui/nvim-surround/blob/master/README.md

_Generated in headless mode with forced plugin load._
