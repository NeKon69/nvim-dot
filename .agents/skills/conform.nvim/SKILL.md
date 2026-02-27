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
require("conform").format(p1, p2)
require("conform").format_lines(p1, p2, p3, p4)
require("conform").formatexpr(p1)
require("conform").formatters -- table
require("conform").formatters_by_ft -- table
require("conform").get_formatter_config(p1, p2)
require("conform").get_formatter_info(p1, p2)
require("conform").list_all_formatters()
require("conform").list_formatters(p1)
require("conform").list_formatters_for_buffer(p1)
require("conform").list_formatters_to_run(p1)
require("conform").notify_no_formatters -- boolean
require("conform").notify_on_error -- boolean
require("conform").resolve_formatters(p1, p2, p3, p4)
require("conform").setup(p1)
```

## Harder Calls (quick notes)

- `require("conform").format_lines(p1, p2, p3, p4)`: argument contract may be non-obvious; check :help/README.
- `require("conform").resolve_formatters(p1, p2, p3, p4)`: argument contract may be non-obvious; check :help/README.
- `require("conform").format(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("conform").get_formatter_config(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("conform").get_formatter_info(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("conform").formatexpr(p1)`: argument contract may be non-obvious; check :help/README.
- `require("conform").list_formatters(p1)`: argument contract may be non-obvious; check :help/README.
- `require("conform").list_formatters_for_buffer(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help conform` and `:help conform.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/conform.nvim/README.md`
- GitHub README: https://github.com/stevearc/conform.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
