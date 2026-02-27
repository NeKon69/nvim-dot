# Telescope.nvim API Reference

This file is generated for plugin `nvim-telescope/telescope.nvim` and module `telescope`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:Telescope
```

## Module API (`telescope`)

```lua
require("telescope") -- table
require("telescope").__format_setup_keys()
require("telescope").extensions -- table
require("telescope").load_extension(p1)
require("telescope").register_extension(p1)
require("telescope").setup(p1)
```

## Harder Calls (quick notes)

- `require("telescope").load_extension(p1)`: argument contract may be non-obvious; check :help/README.
- `require("telescope").register_extension(p1)`: argument contract may be non-obvious; check :help/README.
- `require("telescope").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("telescope").__format_setup_keys()`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help telescope` and `:help telescope.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/telescope.nvim/README.md`
- GitHub README: https://github.com/nvim-telescope/telescope.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
