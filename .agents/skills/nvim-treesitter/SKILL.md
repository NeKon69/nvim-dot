# Nvim-treesitter API Reference

This file is generated for plugin `nvim-treesitter/nvim-treesitter` and module `nvim-treesitter`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:TSBufDisable
:TSBufEnable
:TSBufToggle
:TSConfigInfo
:TSDisable
:TSEditQuery
:TSEditQueryUserAfter
:TSEnable
:TSInstall
:TSInstallFromGrammar
:TSInstallInfo
:TSInstallSync
:TSModuleInfo
:TSToggle
:TSUninstall
:TSUpdate
:TSUpdateSync
```

## Module API (`nvim-treesitter`)

```lua
require("nvim-treesitter") -- table
require("nvim-treesitter").define_modules(p1)
require("nvim-treesitter").setup()
require("nvim-treesitter").statusline(p1)
```

## Harder Calls (quick notes)

- `require("nvim-treesitter").define_modules(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-treesitter").statusline(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-treesitter").setup()`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help nvim-treesitter` and `:help nvim-treesitter.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-treesitter/README.md`
- GitHub README: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md

_Generated in headless mode with forced plugin load._
