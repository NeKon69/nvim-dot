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
require("lazygit").lazygit(path)
require("lazygit").lazygitconfig()
require("lazygit").lazygitcurrentfile()
require("lazygit").lazygitfilter(path, git_root)
require("lazygit").lazygitfiltercurrentfile()
require("lazygit").lazygitlog(path)
require("lazygit").project_root_dir()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help lazygit`, the local README, and the GitHub README listed below.

- `require("lazygit").lazygitfilter(path, git_root)`
- `require("lazygit").lazygit(path)`
- `require("lazygit").lazygitlog(path)`
- `require("lazygit").lazygitconfig()`
- `require("lazygit").lazygitcurrentfile()`
- `require("lazygit").lazygitfiltercurrentfile()`
- `require("lazygit").project_root_dir()`

## References

- Help: `:help lazygit` and `:help lazygit.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/lazygit.nvim/README.md`
- GitHub README: https://github.com/kdheepak/lazygit.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
