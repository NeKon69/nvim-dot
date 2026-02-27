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
require("nvim-tree").change_dir(p1)
require("nvim-tree").change_root(p1, p2)
require("nvim-tree").get_config()
require("nvim-tree").init_root -- string
require("nvim-tree").open_on_directory()
require("nvim-tree").purge_all_state()
require("nvim-tree").setup(p1)
require("nvim-tree").tab_enter()
```

## Harder Calls (quick notes)

- `require("nvim-tree").change_root(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-tree").change_dir(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-tree").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("nvim-tree").get_config()`: setup entrypoint; call once and keep opts explicit.
- `require("nvim-tree").open_on_directory()`: UI/state entrypoint; verify window/buffer context before calling.
- `require("nvim-tree").purge_all_state()`: argument contract may be non-obvious; check :help/README.
- `require("nvim-tree").tab_enter()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help nvim-tree` and `:help nvim-tree.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-tree.lua/README.md`
- GitHub README: https://github.com/nvim-tree/nvim-tree.lua/blob/master/README.md

_Generated in headless mode with forced plugin load._
