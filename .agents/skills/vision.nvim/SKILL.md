# Vision.nvim API Reference

This file is generated for plugin `azorng/vision.nvim` and module `vision`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`vision`)

```lua
require("vision") -- table
require("vision").capture(config)
require("vision").consume_attachment()
require("vision").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help vision`, the local README, and the GitHub README listed below.

- `require("vision").capture(config)`
- `require("vision").setup(opts)`
- `require("vision").consume_attachment()`

## References

- Help: `:help vision` and `:help vision.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/vision.nvim/README.md`
- GitHub README: https://github.com/azorng/vision.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
