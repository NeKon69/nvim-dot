# Toggleterm.nvim API Reference

This file is generated for plugin `akinsho/toggleterm.nvim` and module `toggleterm`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`toggleterm`)

```lua
require("toggleterm") -- table
require("toggleterm").exec(cmd, num, size, dir, direction, name, go_back, open)
require("toggleterm").exec_command(args, count)
require("toggleterm").send_lines_to_terminal(selection_type, trim_spaces, cmd_data)
require("toggleterm").setup(user_prefs)
require("toggleterm").toggle(count, size, dir, direction, name)
require("toggleterm").toggle_all(force)
require("toggleterm").toggle_command(args, count)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help toggleterm`, the local README, and the GitHub README listed below.

- `require("toggleterm").exec(cmd, num, size, dir, direction, name, go_back, open)`
- `require("toggleterm").toggle(count, size, dir, direction, name)`
- `require("toggleterm").send_lines_to_terminal(selection_type, trim_spaces, cmd_data)`
- `require("toggleterm").exec_command(args, count)`
- `require("toggleterm").toggle_command(args, count)`
- `require("toggleterm").setup(user_prefs)`
- `require("toggleterm").toggle_all(force)`

## References

- Help: `:help toggleterm` and `:help toggleterm.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/toggleterm.nvim/README.md`
- GitHub README: https://github.com/akinsho/toggleterm.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
