# User.exit_debug API Reference

This file is generated for source `lua/user/exit_debug.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:ExitDebugClear

:ExitDebugOpen

```

## Module API (`user.exit_debug`)

```lua
require("user.exit_debug").setup(opts)

event = "ExitPre"

event = "QuitPre"

event = "User"

event = "VimEnter"

event = "VimLeave"

event = "VimLeavePre"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `setup(opts)`


## References

_No plugin/module references detected._

_Generated in headless mode from static file analysis._
