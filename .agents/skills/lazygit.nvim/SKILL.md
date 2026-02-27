# Lazygit.nvim API Reference

This file is generated for plugin `kdheepak/lazygit.nvim` and module `lazygit`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:LazyGit
:LazyGitConfig
:LazyGitCurrentFile
:LazyGitFilter
:LazyGitFilterCurrentFile
:LazyGitLog
```

## Module API (`lazygit`)

```lua
require("lazygit") -- table
require("lazygit").lazygit(p1)
require("lazygit").lazygitconfig()
require("lazygit").lazygitcurrentfile()
require("lazygit").lazygitfilter(p1, p2)
require("lazygit").lazygitfiltercurrentfile()
require("lazygit").lazygitlog(p1)
require("lazygit").project_root_dir()
```

## Harder Calls (quick notes)

- `require("lazygit").lazygitfilter(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("lazygit").lazygit(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lazygit").lazygitlog(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lazygit").lazygitconfig()`: setup entrypoint; call once and keep opts explicit.
- `require("lazygit").lazygitcurrentfile()`: argument contract may be non-obvious; check :help/README.
- `require("lazygit").lazygitfiltercurrentfile()`: argument contract may be non-obvious; check :help/README.
- `require("lazygit").project_root_dir()`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help lazygit` and `:help lazygit.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lazygit.nvim/README.md`
- GitHub README: https://github.com/kdheepak/lazygit.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
