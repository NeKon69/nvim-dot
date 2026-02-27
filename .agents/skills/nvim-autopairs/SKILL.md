# Nvim-autopairs API Reference

This file is generated for plugin `windwp/nvim-autopairs` and module `nvim-autopairs`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`nvim-autopairs`)

```lua
require("nvim-autopairs") -- table
require("nvim-autopairs").add_rule(p1)
require("nvim-autopairs").add_rules(p1)
require("nvim-autopairs").autopairs_afterquote(p1, p2)
require("nvim-autopairs").autopairs_bs(p1)
require("nvim-autopairs").autopairs_c_h(p1)
require("nvim-autopairs").autopairs_c_w(p1)
require("nvim-autopairs").autopairs_closequote_expr()
require("nvim-autopairs").autopairs_cr(p1)
require("nvim-autopairs").autopairs_insert(p1, p2)
require("nvim-autopairs").autopairs_map(p1, p2)
require("nvim-autopairs").check_break_line_char()
require("nvim-autopairs").clear_rules()
require("nvim-autopairs").completion_confirm()
require("nvim-autopairs").disable()
require("nvim-autopairs").enable()
require("nvim-autopairs").esc(p1)
require("nvim-autopairs").force_attach(p1)
require("nvim-autopairs").get_buf_rules(p1)
require("nvim-autopairs").get_rule(p1)
require("nvim-autopairs").get_rules(p1)
require("nvim-autopairs").map_cr()
require("nvim-autopairs").on_attach(p1)
require("nvim-autopairs").remove_rule(p1)
require("nvim-autopairs").set_buf_rule(p1, p2)
require("nvim-autopairs").setup(p1)
require("nvim-autopairs").state -- table
require("nvim-autopairs").state.buf_ts -- table
require("nvim-autopairs").state.disabled -- boolean
require("nvim-autopairs").state.rules -- table
require("nvim-autopairs").toggle()
```

## Harder Calls (quick notes)

- `require("nvim-autopairs").autopairs_afterquote(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").autopairs_insert(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").autopairs_map(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").set_buf_rule(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").add_rule(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").add_rules(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").autopairs_bs(p1)`: argument contract may be non-obvious; check :help/README.
- `require("nvim-autopairs").autopairs_c_h(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help nvim-autopairs` and `:help nvim-autopairs.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-autopairs/README.md`
- GitHub README: https://github.com/windwp/nvim-autopairs/blob/master/README.md

_Generated in headless mode with forced plugin load._
