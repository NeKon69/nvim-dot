# Nvim-tree.lua API Reference

This file is generated for plugin `nvim-tree/nvim-tree.lua` and module `nvim-tree`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:NvimTreeClipboard
:NvimTreeClose
:NvimTreeCollapse
:NvimTreeCollapseKeepBuffers
:NvimTreeFindFile
:NvimTreeFindFileToggle
:NvimTreeFocus
:NvimTreeHiTest
:NvimTreeOpen
:NvimTreeRefresh
:NvimTreeResize
:NvimTreeToggle
```

## Module API (`nvim-tree`)

```lua
require("nvim-tree") -- table
require("nvim-tree").change_dir(name)
require("nvim-tree").change_root(path, bufnr)
require("nvim-tree").get_config()
require("nvim-tree").init_root -- string
require("nvim-tree").open_on_directory()
require("nvim-tree").purge_all_state()
require("nvim-tree").setup(conf)
require("nvim-tree").tab_enter()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help nvim-tree`, the local README, and the GitHub README listed below.

- `require("nvim-tree").change_root(path, bufnr)`
- `require("nvim-tree").change_dir(name)`
- `require("nvim-tree").setup(conf)`
- `require("nvim-tree").get_config()`
- `require("nvim-tree").open_on_directory()`
- `require("nvim-tree").purge_all_state()`
- `require("nvim-tree").tab_enter()`

## References

- Help: `:help nvim-tree` and `:help nvim-tree.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-tree.lua/README.md`
- GitHub README: https://github.com/nvim-tree/nvim-tree.lua/blob/master/README.md

_Generated in headless mode with forced plugin load._
