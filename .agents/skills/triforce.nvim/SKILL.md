# Triforce.nvim API Reference

This file is generated for plugin `gisketch/triforce.nvim` and module `triforce`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`triforce`)

```lua
require("triforce") -- table
require("triforce").close_config()
require("triforce").debug_achievement()
require("triforce").debug_fix_level()
require("triforce").debug_languages()
require("triforce").debug_xp()
require("triforce").export_stats()
require("triforce").export_stats_to_json(file, indent)
require("triforce").export_stats_to_md(file)
require("triforce").get_stats()
require("triforce").new_achievements(achievements)
require("triforce").open_config()
require("triforce").reset_stats()
require("triforce").save_stats()
require("triforce").setup(opts)
require("triforce").show_profile(tab)
require("triforce").toggle_config()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help triforce`, the local README, and the GitHub README listed below.

- `require("triforce").export_stats_to_json(file, indent)`
- `require("triforce").export_stats_to_md(file)`
- `require("triforce").new_achievements(achievements)`
- `require("triforce").setup(opts)`
- `require("triforce").show_profile(tab)`
- `require("triforce").close_config()`
- `require("triforce").debug_achievement()`
- `require("triforce").debug_fix_level()`

## References

- Help: `:help triforce` and `:help triforce.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/triforce.nvim/README.md`
- GitHub README: https://github.com/gisketch/triforce.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
