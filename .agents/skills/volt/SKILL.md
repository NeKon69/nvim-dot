# Volt API Reference

This file is generated for plugin `nvzone/volt` and module `volt`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`volt`)

```lua
require("volt") -- table
require("volt").close(buf)
require("volt").gen_data(data)
require("volt").mappings(val)
require("volt").redraw(buf, names)
require("volt").run(buf, opts)
require("volt").set_empty_lines(buf, n, w)
require("volt").toggle_func(open_func, ui_state)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help volt`, the local README, and the GitHub README listed below.

- `require("volt").set_empty_lines(buf, n, w)`
- `require("volt").redraw(buf, names)`
- `require("volt").run(buf, opts)`
- `require("volt").toggle_func(open_func, ui_state)`
- `require("volt").close(buf)`
- `require("volt").gen_data(data)`
- `require("volt").mappings(val)`

## References

- Help: `:help volt` and `:help volt.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/volt/README.md`
- GitHub README: https://github.com/nvzone/volt/blob/master/README.md

_Generated in headless mode with forced plugin load._
