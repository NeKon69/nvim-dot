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
require("hardtime").setup(user_config)
require("hardtime").toggle()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help hardtime`, the local README, and the GitHub README listed below.

- `require("hardtime").setup(user_config)`
- `require("hardtime").disable()`
- `require("hardtime").enable()`
- `require("hardtime").toggle()`

## References

- Help: `:help hardtime` and `:help hardtime.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/hardtime.nvim/README.md`
- GitHub README: https://github.com/m4xshen/hardtime.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
