# Rainbow-delimiters.nvim API Reference

This file is generated for plugin `HiPhish/rainbow-delimiters.nvim` and module `rainbow-delimiters`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`rainbow-delimiters`)

```lua
require("rainbow-delimiters") -- table
require("rainbow-delimiters").disable(p1)
require("rainbow-delimiters").enable(p1)
require("rainbow-delimiters").hlgroup_at(p1)
require("rainbow-delimiters").is_enabled(p1)
require("rainbow-delimiters").strategy -- table
require("rainbow-delimiters").strategy.global -- string
require("rainbow-delimiters").strategy.local -- string
require("rainbow-delimiters").strategy.noop -- string
require("rainbow-delimiters").toggle(p1)
```

## Harder Calls (quick notes)

- `require("rainbow-delimiters").disable(p1)`: argument contract may be non-obvious; check :help/README.
- `require("rainbow-delimiters").enable(p1)`: argument contract may be non-obvious; check :help/README.
- `require("rainbow-delimiters").hlgroup_at(p1)`: argument contract may be non-obvious; check :help/README.
- `require("rainbow-delimiters").is_enabled(p1)`: argument contract may be non-obvious; check :help/README.
- `require("rainbow-delimiters").toggle(p1)`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help rainbow-delimiters` and `:help rainbow-delimiters.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/rainbow-delimiters.nvim/README.md`
- GitHub README: https://github.com/HiPhish/rainbow-delimiters.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
