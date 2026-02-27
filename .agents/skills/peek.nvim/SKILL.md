# Peek.nvim API Reference

This file is generated for plugin `toppair/peek.nvim` and module `peek`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`peek`)

```lua
require("peek") -- table
require("peek").close(...)
require("peek").is_open(...)
require("peek").open(...)
require("peek").setup(p1)
```

## Harder Calls (quick notes)

- `require("peek").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("peek").close(...)`: argument contract may be non-obvious; check :help/README.
- `require("peek").is_open(...)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("peek").open(...)`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help peek` and `:help peek.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/peek.nvim/README.md`
- GitHub README: https://github.com/toppair/peek.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
