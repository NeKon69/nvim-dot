# User.history API Reference

This file is generated for source `lua/user/history.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`user.history`)

```lua
require("user.history").back()

require("user.history").forward()

require("user.history").get_project_root()

require("user.history").list_history()

require("user.history").nav_history(direction)

require("user.history").record(action_name)

require("user.history").setup(opts)

require("user.history").wrap_jump(cmd, action)

event = "BufEnter"

event = "CursorHold"

event = "InsertEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `wrap_jump(cmd, action)`

- `nav_history(direction)`

- `record(action_name)`

- `setup(opts)`

- `back()`

- `forward()`

- `get_project_root()`

- `list_history()`


## References

- `.nvim/history`

- `.nvim/history.jsonl`

- `plenary.path`

- `telescope.actions`

- `telescope.actions.state`

- `telescope.config`

- `telescope.finders`

- `telescope.pickers`


_Generated in headless mode from static file analysis._
