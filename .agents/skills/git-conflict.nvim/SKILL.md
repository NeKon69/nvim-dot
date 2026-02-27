# Git-conflict.nvim API Reference

This file is generated for plugin `akinsho/git-conflict.nvim` and module `git-conflict`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`git-conflict`)

```lua
require("git-conflict") -- table
require("git-conflict").choose(p1)
require("git-conflict").clear(p1)
require("git-conflict").conflict_count(p1)
require("git-conflict").conflicts_to_qf_items(p1)
require("git-conflict").debug_watchers()
require("git-conflict").find_next(p1)
require("git-conflict").find_prev(p1)
require("git-conflict").setup(p1)
```

## Harder Calls (quick notes)

- `require("git-conflict").choose(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").clear(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").conflict_count(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").conflicts_to_qf_items(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").find_next(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").find_prev(p1)`: argument contract may be non-obvious; check :help/README.
- `require("git-conflict").setup(p1)`: setup entrypoint; call once and keep opts explicit.
- `require("git-conflict").debug_watchers()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help git-conflict` and `:help git-conflict.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/git-conflict.nvim/README.md`
- GitHub README: https://github.com/akinsho/git-conflict.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
