# Octo.nvim API Reference

This file is generated for plugin `pwntester/octo.nvim` and module `octo`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`octo`)

```lua
require("octo") -- table
require("octo").configure_octo_buffer(p1)
require("octo").create_buffer(p1, p2, p3, p4, p5)
require("octo").load(p1, p2, p3, p4, p5)
require("octo").load_buffer(p1)
require("octo").on_cursor_hold()
require("octo").render_signs()
require("octo").save_buffer()
require("octo").setup(p1)
require("octo").update_layout_for_current_file()
```

## Harder Calls (quick notes)

- `require("octo").create_buffer(p1, p2, p3, p4, p5)`: argument contract may be non-obvious; check :help/README.
- `require("octo").load(p1, p2, p3, p4, p5)`: argument contract may be non-obvious; check :help/README.
- `require("octo").configure_octo_buffer(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("octo").load_buffer(p1)`: argument contract may be non-obvious; check :help/README.
- `require("octo").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("octo").on_cursor_hold()`: argument contract may be non-obvious; check :help/README.
- `require("octo").render_signs()`: argument contract may be non-obvious; check :help/README.
- `require("octo").save_buffer()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help octo` and `:help octo.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/octo.nvim/README.md`
- GitHub README: https://github.com/pwntester/octo.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
