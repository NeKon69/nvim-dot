# Persistence.nvim API Reference

This file is generated for plugin `folke/persistence.nvim` and module `persistence`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`persistence`)

```lua
require("persistence") -- table
require("persistence")._active -- boolean
require("persistence").active()
require("persistence").branch()
require("persistence").current(p1)
require("persistence").fire(p1)
require("persistence").last()
require("persistence").list()
require("persistence").load(p1)
require("persistence").save()
require("persistence").select()
require("persistence").setup(p1)
require("persistence").start()
require("persistence").stop()
```

## Harder Calls (quick notes)

- `require("persistence").current(p1)`: argument contract may be non-obvious; check :help/README.
- `require("persistence").fire(p1)`: argument contract may be non-obvious; check :help/README.
- `require("persistence").load(p1)`: argument contract may be non-obvious; check :help/README.
- `require("persistence").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("persistence").active()`: argument contract may be non-obvious; check :help/README.
- `require("persistence").branch()`: argument contract may be non-obvious; check :help/README.
- `require("persistence").last()`: argument contract may be non-obvious; check :help/README.
- `require("persistence").list()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help persistence` and `:help persistence.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/persistence.nvim/README.md`
- GitHub README: https://github.com/folke/persistence.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
