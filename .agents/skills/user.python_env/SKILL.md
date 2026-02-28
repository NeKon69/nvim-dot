# User.python_env API Reference

This file is generated for source `lua/user/python_env.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:PyVenvActivate

:PyVenvCreate

:PyVenvStatus

```

## Module API (`user.python_env`)

```lua
require("user.python_env").setup()

vim.keymap.set("n", mapdef.lhs, mapdef.rhs, { desc = mapdef.desc, silent = true })

event = "DirChanged"

event = "TermOpen"

event = "VimEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `setup()`


## References

- `.nvim/venv`


_Generated in headless mode from static file analysis._
