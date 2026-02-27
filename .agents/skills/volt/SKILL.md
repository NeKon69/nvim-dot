# Volt API Reference

This file is generated for plugin `nvzone/volt` and module `volt`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`volt`)

```lua
require("volt") -- table
require("volt").close(p1)
require("volt").gen_data(p1)
require("volt").mappings(p1)
require("volt").redraw(p1, p2)
require("volt").run(p1, p2)
require("volt").set_empty_lines(p1, p2, p3)
require("volt").toggle_func(p1, p2)
```

## Harder Calls (quick notes)

- `require("volt").set_empty_lines(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("volt").redraw(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("volt").run(p1, p2)`: side-effecting call; validate inputs and error paths.
- `require("volt").toggle_func(p1, p2)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("volt").close(p1)`: argument contract may be non-obvious; check :help/README.
- `require("volt").gen_data(p1)`: argument contract may be non-obvious; check :help/README.
- `require("volt").mappings(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help volt` and `:help volt.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/volt/README.md`
- GitHub README: https://github.com/nvzone/volt/blob/master/README.md

_Generated in headless mode with forced plugin load._
