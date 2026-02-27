# Nvim-treesitter-context API Reference

This file is generated for plugin `nvim-treesitter/nvim-treesitter-context` and module `treesitter-context`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:TSContext
```

## Module API (`treesitter-context`)

```lua
require("treesitter-context") -- table
require("treesitter-context").config -- table
require("treesitter-context").config.update(p1)
require("treesitter-context").disable()
require("treesitter-context").enable()
require("treesitter-context").enabled()
require("treesitter-context").go_to_context(p1)
require("treesitter-context").setup(p1)
require("treesitter-context").toggle()
```

## Harder Calls (quick notes)

- `require("treesitter-context").config.update(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("treesitter-context").go_to_context(p1)`: argument contract may be non-obvious; check :help/README.
- `require("treesitter-context").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("treesitter-context").disable()`: argument contract may be non-obvious; check :help/README.
- `require("treesitter-context").enable()`: argument contract may be non-obvious; check :help/README.
- `require("treesitter-context").enabled()`: argument contract may be non-obvious; check :help/README.
- `require("treesitter-context").toggle()`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help treesitter-context` and `:help treesitter-context.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-treesitter-context/README.md`
- GitHub README: https://github.com/nvim-treesitter/nvim-treesitter-context/blob/master/README.md

_Generated in headless mode with forced plugin load._
