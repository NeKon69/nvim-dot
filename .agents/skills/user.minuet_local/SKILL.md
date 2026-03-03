# User.minuet_local API Reference

This file is generated for source `lua/user/minuet_local.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:MinuetLocalStatus

```

## Module API (`user.minuet_local`)

```lua
require("user.minuet_local").setup(opts)

require("user.minuet_local").start_server()

require("user.minuet_local").stop_server()

event = "VimEnter"

event = "VimLeavePre"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `setup(opts)`

- `start_server()`

- `stop_server()`


## References

_No plugin/module references detected._

_Generated in headless mode from static file analysis._
