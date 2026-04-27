# Code-preview.nvim API Reference

This file is generated for plugin `Cannon07/code-preview.nvim` and module `code-preview`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`code-preview`)

```lua
require("code-preview") -- table
require("code-preview").config -- table
require("code-preview").hook_context(file_path)
require("code-preview").setup(user_config)
require("code-preview").status()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help code-preview`, the local README, and the GitHub README listed below.

- `require("code-preview").hook_context(file_path)`
- `require("code-preview").setup(user_config)`
- `require("code-preview").status()`

## References

- Help: `:help code-preview` and `:help code-preview.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/code-preview.nvim/README.md`
- GitHub README: https://github.com/Cannon07/code-preview.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
