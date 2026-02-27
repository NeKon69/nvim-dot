# Hardtime.nvim API Reference

This file is generated for plugin `m4xshen/hardtime.nvim` and module `hardtime`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`hardtime`)

```lua
require("hardtime") -- table
require("hardtime").disable()
require("hardtime").enable()
require("hardtime").is_plugin_enabled -- boolean
require("hardtime").setup(p1)
require("hardtime").toggle()
```

## Harder Calls (quick notes)

- `require("hardtime").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("hardtime").disable()`: argument contract may be non-obvious; check :help/README.
- `require("hardtime").enable()`: argument contract may be non-obvious; check :help/README.
- `require("hardtime").toggle()`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help hardtime` and `:help hardtime.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/hardtime.nvim/README.md`
- GitHub README: https://github.com/m4xshen/hardtime.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
