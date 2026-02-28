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
require("nvim-treesitter").define_modules(mod_defs)
require("nvim-treesitter").setup()
require("nvim-treesitter").statusline(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help nvim-treesitter`, the local README, and the GitHub README listed below.

- `require("nvim-treesitter").define_modules(mod_defs)`
- `require("nvim-treesitter").statusline(opts)`
- `require("nvim-treesitter").setup()`

## References

- Help: `:help nvim-treesitter` and `:help nvim-treesitter.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-treesitter/README.md`
- GitHub README: https://github.com/nvim-treesitter/nvim-treesitter/blob/master/README.md

_Generated in headless mode with forced plugin load._
