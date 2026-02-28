# Which-key.nvim API Reference

This file is generated for plugin `folke/which-key.nvim` and module `which-key`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`which-key`)

```lua
require("which-key") -- table
require("which-key")._queue -- table
require("which-key").add(mappings, opts)
require("which-key").did_setup -- boolean
require("which-key").register(mappings, opts)
require("which-key").setup(opts)
require("which-key").show(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help which-key`, the local README, and the GitHub README listed below.

- `require("which-key").add(mappings, opts)`
- `require("which-key").register(mappings, opts)`
- `require("which-key").setup(opts)`
- `require("which-key").show(opts)`

## References

- Help: `:help which-key` and `:help which-key.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/which-key.nvim/README.md`
- GitHub README: https://github.com/folke/which-key.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
