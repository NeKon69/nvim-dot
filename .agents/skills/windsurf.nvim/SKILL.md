# Windsurf.nvim API Reference

This file is generated for plugin `Exafunction/windsurf.nvim` and module `codeium`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`codeium`)

```lua
require("codeium") -- table
require("codeium").chat()
require("codeium").disable()
require("codeium").enable()
require("codeium").setup(p1)
require("codeium").toggle()
```

## Harder Calls (quick notes)

- `require("codeium").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("codeium").chat()`: argument contract may be non-obvious; check :help/README.
- `require("codeium").disable()`: argument contract may be non-obvious; check :help/README.
- `require("codeium").enable()`: argument contract may be non-obvious; check :help/README.
- `require("codeium").toggle()`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help codeium` and `:help codeium.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/windsurf.nvim/README.md`
- GitHub README: https://github.com/Exafunction/windsurf.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
