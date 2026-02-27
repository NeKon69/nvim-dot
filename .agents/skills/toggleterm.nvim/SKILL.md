# Toggleterm.nvim API Reference

This file is generated for plugin `akinsho/toggleterm.nvim` and module `toggleterm`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`toggleterm`)

```lua
require("toggleterm") -- table
require("toggleterm").exec(p1, p2, p3, p4, p5, p6, p7, p8)
require("toggleterm").exec_command(p1, p2)
require("toggleterm").send_lines_to_terminal(p1, p2, p3)
require("toggleterm").setup(p1)
require("toggleterm").toggle(p1, p2, p3, p4, p5)
require("toggleterm").toggle_all(p1)
require("toggleterm").toggle_command(p1, p2)
```

## Harder Calls (quick notes)

- `require("toggleterm").exec(p1, p2, p3, p4, p5, p6, p7, p8)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("toggleterm").toggle(p1, p2, p3, p4, p5)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("toggleterm").send_lines_to_terminal(p1, p2, p3)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("toggleterm").exec_command(p1, p2)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("toggleterm").toggle_command(p1, p2)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("toggleterm").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("toggleterm").toggle_all(p1)`: UI/state entrypoint; verify window/buffer context before calling.

## References

- Help: `:help toggleterm` and `:help toggleterm.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/toggleterm.nvim/README.md`
- GitHub README: https://github.com/akinsho/toggleterm.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
