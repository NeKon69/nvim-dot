# User.folding API Reference

This file is generated for source `lua/user/folding.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:FoldingReload

```

## Module API (`user.folding`)

```lua
require("user.folding").collapse_current_node()

require("user.folding").open_all_folds()

require("user.folding").open_current_fold_or_enter()

require("user.folding").refresh_ufo_renderer()

require("user.folding").setup()

require("user.folding").toggle()

require("user.folding").ufo_fold_virt_text_handler(virt_text, lnum, end_lnum, width, truncate, ctx)

require("user.folding").ufo_opts()

vim.keymap.set("n", "<CR>", M.open_current_fold_or_enter, {

vim.keymap.set("n", "<leader>uC", M.collapse_current_node, {

vim.keymap.set("n", "<leader>uR", M.open_all_folds, {

vim.keymap.set("n", "<leader>uz", M.toggle, {

event = "BufEnter"

event = "BufWinEnter"

event = "BufWritePost"

event = "SessionLoadPost"

event = "VimEnter"

event = "WinEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `ufo_fold_virt_text_handler(virt_text, lnum, end_lnum, width, truncate, ctx)`

- `collapse_current_node()`

- `open_all_folds()`

- `open_current_fold_or_enter()`

- `refresh_ufo_renderer()`

- `setup()`

- `toggle()`

- `ufo_opts()`


## References

- `textDocument/foldingRange`

- `ufo`


_Generated in headless mode from static file analysis._
