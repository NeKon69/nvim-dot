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
require("persistence").current(opts)
require("persistence").fire(event)
require("persistence").last()
require("persistence").list()
require("persistence").load(opts)
require("persistence").save()
require("persistence").select()
require("persistence").setup(opts)
require("persistence").start()
require("persistence").stop()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help persistence`, the local README, and the GitHub README listed below.

- `require("persistence").current(opts)`
- `require("persistence").fire(event)`
- `require("persistence").load(opts)`
- `require("persistence").setup(opts)`
- `require("persistence").active()`
- `require("persistence").branch()`
- `require("persistence").last()`
- `require("persistence").list()`

## References

- Help: `:help persistence` and `:help persistence.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/persistence.nvim/README.md`
- GitHub README: https://github.com/folke/persistence.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
