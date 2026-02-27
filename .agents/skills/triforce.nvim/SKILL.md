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
require("triforce").export_stats_to_json(p1, p2)
require("triforce").export_stats_to_md(p1)
require("triforce").get_stats()
require("triforce").new_achievements(p1)
require("triforce").open_config()
require("triforce").reset_stats()
require("triforce").save_stats()
require("triforce").setup(p1)
require("triforce").show_profile(p1)
require("triforce").toggle_config()
```

## Harder Calls (quick notes)

- `require("triforce").export_stats_to_json(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("triforce").export_stats_to_md(p1)`: argument contract may be non-obvious; check :help/README.
- `require("triforce").new_achievements(p1)`: argument contract may be non-obvious; check :help/README.
- `require("triforce").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("triforce").show_profile(p1)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("triforce").close_config()`: setup entrypoint; call once and keep opts explicit.
- `require("triforce").debug_achievement()`: argument contract may be non-obvious; check :help/README.
- `require("triforce").debug_fix_level()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help triforce` and `:help triforce.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/triforce.nvim/README.md`
- GitHub README: https://github.com/gisketch/triforce.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
