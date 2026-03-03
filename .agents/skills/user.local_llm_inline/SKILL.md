# User.local_llm_inline API Reference

This file is generated for source `lua/user/local_llm_inline.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`user.local_llm_inline`)

```lua
require("user.local_llm_inline")._consume_pending_insert()

require("user.local_llm_inline").accept()

require("user.local_llm_inline").accept_word()

require("user.local_llm_inline").clear()

require("user.local_llm_inline").cycle_next()

require("user.local_llm_inline").cycle_prev()

require("user.local_llm_inline").setup(opts)

require("user.local_llm_inline").start_server()

require("user.local_llm_inline").stop_server()

vim.keymap.set(

vim.keymap.set("i", km.clear, M.clear, { silent = true, desc = "Local LLM clear" })

vim.keymap.set("i", km.next, M.cycle_next, { silent = true, desc = "Local LLM next" })

vim.keymap.set("i", km.prev, M.cycle_prev, { silent = true, desc = "Local LLM prev" })

event = "BufEnter"

event = "BufLeave"

event = "ColorScheme"

event = "InsertCharPre"

event = "InsertEnter"

event = "InsertLeave"

event = "TextChangedI"

event = "VimEnter"

event = "VimLeavePre"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `setup(opts)`

- `_consume_pending_insert()`

- `accept()`

- `accept_word()`

- `clear()`

- `cycle_next()`

- `cycle_prev()`

- `start_server()`


## References

- `textDocument/definition`

- `textDocument/hover`

- `textDocument/signatureHelp`


_Generated in headless mode from static file analysis._
