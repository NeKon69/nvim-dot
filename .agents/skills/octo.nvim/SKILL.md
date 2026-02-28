# Octo.nvim API Reference

This file is generated for plugin `pwntester/octo.nvim` and module `octo`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`octo`)

```lua
require("octo") -- table
require("octo").configure_octo_buffer(bufnr)
require("octo").create_buffer(kind, obj, repo, create, hostname)
require("octo").load(repo, kind, id, hostname, cb)
require("octo").load_buffer(opts)
require("octo").on_cursor_hold()
require("octo").render_signs()
require("octo").save_buffer()
require("octo").setup(user_config)
require("octo").update_layout_for_current_file()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help octo`, the local README, and the GitHub README listed below.

- `require("octo").create_buffer(kind, obj, repo, create, hostname)`
- `require("octo").load(repo, kind, id, hostname, cb)`
- `require("octo").configure_octo_buffer(bufnr)`
- `require("octo").load_buffer(opts)`
- `require("octo").setup(user_config)`
- `require("octo").on_cursor_hold()`
- `require("octo").render_signs()`
- `require("octo").save_buffer()`

## References

- Help: `:help octo` and `:help octo.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/octo.nvim/README.md`
- GitHub README: https://github.com/pwntester/octo.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
