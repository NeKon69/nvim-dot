# Smart-splits.nvim API Reference

This file is generated for plugin `mrjones2014/smart-splits.nvim` and module `smart-splits`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:SmartCursorMoveDown
:SmartCursorMoveLeft
:SmartCursorMoveRight
:SmartCursorMoveUp
:SmartResizeDown
:SmartResizeLeft
:SmartResizeRight
:SmartResizeUp
:SmartSplitsLog
:SmartSplitsLogLevel
:SmartSwapDown
:SmartSwapLeft
:SmartSwapRight
:SmartSwapUp
```

## Module API (`smart-splits`)

```lua
require("smart-splits") -- table
require("smart-splits").move_cursor_down(...)
require("smart-splits").move_cursor_left(...)
require("smart-splits").move_cursor_previous(...)
require("smart-splits").move_cursor_right(...)
require("smart-splits").move_cursor_up(...)
require("smart-splits").resize_down(...)
require("smart-splits").resize_left(...)
require("smart-splits").resize_right(...)
require("smart-splits").resize_up(...)
require("smart-splits").setup(p1)
require("smart-splits").swap_buf_down(...)
require("smart-splits").swap_buf_left(...)
require("smart-splits").swap_buf_right(...)
require("smart-splits").swap_buf_up(...)
```

## Harder Calls (quick notes)

- `require("smart-splits").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("smart-splits").move_cursor_down(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").move_cursor_left(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").move_cursor_previous(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").move_cursor_right(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").move_cursor_up(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").resize_down(...)`: argument contract may be non-obvious; check :help/README.
- `require("smart-splits").resize_left(...)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help smart-splits` and `:help smart-splits.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/smart-splits.nvim/README.md`
- GitHub README: https://github.com/mrjones2014/smart-splits.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
