# Nvim-autopairs API Reference

This file is generated for plugin `windwp/nvim-autopairs` and module `nvim-autopairs`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`nvim-autopairs`)

```lua
require("nvim-autopairs") -- table
require("nvim-autopairs").add_rule(rule)
require("nvim-autopairs").add_rules(rules)
require("nvim-autopairs").autopairs_afterquote(line, key_char)
require("nvim-autopairs").autopairs_bs(bufnr)
require("nvim-autopairs").autopairs_c_h(bufnr)
require("nvim-autopairs").autopairs_c_w(bufnr)
require("nvim-autopairs").autopairs_closequote_expr()
require("nvim-autopairs").autopairs_cr(bufnr)
require("nvim-autopairs").autopairs_insert(bufnr, char)
require("nvim-autopairs").autopairs_map(bufnr, char)
require("nvim-autopairs").check_break_line_char()
require("nvim-autopairs").clear_rules()
require("nvim-autopairs").completion_confirm()
require("nvim-autopairs").disable()
require("nvim-autopairs").enable()
require("nvim-autopairs").esc(cmd)
require("nvim-autopairs").force_attach(bufnr)
require("nvim-autopairs").get_buf_rules(bufnr)
require("nvim-autopairs").get_rule(start_pair)
require("nvim-autopairs").get_rules(start_pair)
require("nvim-autopairs").map_cr()
require("nvim-autopairs").on_attach(bufnr)
require("nvim-autopairs").remove_rule(pair)
require("nvim-autopairs").set_buf_rule(rules, bufnr)
require("nvim-autopairs").setup(opt)
require("nvim-autopairs").state -- table
require("nvim-autopairs").state.buf_ts -- table
require("nvim-autopairs").state.disabled -- boolean
require("nvim-autopairs").state.rules -- table
require("nvim-autopairs").toggle()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help nvim-autopairs`, the local README, and the GitHub README listed below.

- `require("nvim-autopairs").autopairs_afterquote(line, key_char)`
- `require("nvim-autopairs").autopairs_insert(bufnr, char)`
- `require("nvim-autopairs").autopairs_map(bufnr, char)`
- `require("nvim-autopairs").set_buf_rule(rules, bufnr)`
- `require("nvim-autopairs").add_rule(rule)`
- `require("nvim-autopairs").add_rules(rules)`
- `require("nvim-autopairs").autopairs_bs(bufnr)`
- `require("nvim-autopairs").autopairs_c_h(bufnr)`

## References

- Help: `:help nvim-autopairs` and `:help nvim-autopairs.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-autopairs/README.md`
- GitHub README: https://github.com/windwp/nvim-autopairs/blob/master/README.md

_Generated in headless mode with forced plugin load._
