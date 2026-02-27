# Which-key.nvim API Reference

This file is generated for plugin `folke/which-key.nvim` and module `which-key`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`which-key`)

```lua
require("which-key") -- table
require("which-key")._queue -- table
require("which-key").add(p1, p2)
require("which-key").did_setup -- boolean
require("which-key").register(p1, p2)
require("which-key").setup(p1)
require("which-key").show(p1)
```

## Harder Calls (quick notes)

- `require("which-key").add(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("which-key").register(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("which-key").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("which-key").show(p1)`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help which-key` and `:help which-key.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/which-key.nvim/README.md`
- GitHub README: https://github.com/folke/which-key.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
