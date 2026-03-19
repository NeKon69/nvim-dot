# User.lspconfig API Reference

This file is generated for source `lua/user/lspconfig.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`user.lspconfig`)

```lua
vim.keymap.set("n", lhs, rhs, {

event = "BufEnter"

event = "CursorHold"

event = "CursorHoldI"

event = "CursorMoved"

event = "InsertEnter"

event = "InsertLeave"

event = "LspAttach"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `cmp_nvim_lsp`

- `lspsaga.hover`

- `textDocument/hover`


_Generated in headless mode from static file analysis._
