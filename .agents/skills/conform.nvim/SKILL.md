# Conform.nvim API Reference

This file is generated for plugin `stevearc/conform.nvim` and module `conform`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:ConformInfo
```

## Module API (`conform`)

```lua
require("conform") -- table
require("conform").default_format_opts -- table
require("conform").format(opts, callback)
require("conform").format_lines(formatter_names, lines, opts, callback)
require("conform").formatexpr(opts)
require("conform").formatters -- table
require("conform").formatters_by_ft -- table
require("conform").get_formatter_config(formatter, bufnr)
require("conform").get_formatter_info(formatter, bufnr)
require("conform").list_all_formatters()
require("conform").list_formatters(bufnr)
require("conform").list_formatters_for_buffer(bufnr)
require("conform").list_formatters_to_run(bufnr)
require("conform").notify_no_formatters -- boolean
require("conform").notify_on_error -- boolean
require("conform").resolve_formatters(names, bufnr, warn_on_missing, stop_after_first)
require("conform").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help conform`, the local README, and the GitHub README listed below.

- `require("conform").format_lines(formatter_names, lines, opts, callback)`
- `require("conform").resolve_formatters(names, bufnr, warn_on_missing, stop_after_first)`
- `require("conform").format(opts, callback)`
- `require("conform").get_formatter_config(formatter, bufnr)`
- `require("conform").get_formatter_info(formatter, bufnr)`
- `require("conform").formatexpr(opts)`
- `require("conform").list_formatters(bufnr)`
- `require("conform").list_formatters_for_buffer(bufnr)`

## References

- Help: `:help conform` and `:help conform.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/conform.nvim/README.md`
- GitHub README: https://github.com/stevearc/conform.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
