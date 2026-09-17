# User.init API Reference

This file is generated for source `local/opencode-review.nvim/lua/opencode-review/init.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

```vim
:OpencodeReviewAcceptFile

:OpencodeReviewComment

:OpencodeReviewReject

:OpencodeReviewStart

:OpencodeReviewStop

```

## Module API (`opencode-review.init`)

```lua
require("opencode-review.init").accept_all()

require("opencode-review.init").accept_file()

require("opencode-review.init").next_hunk()

require("opencode-review.init").prev_hunk()

require("opencode-review.init").reject_request()

require("opencode-review.init").setup(user_opts)

require("opencode-review.init").start()

require("opencode-review.init").stop()

vim.keymap.set("n", "[c", function()

vim.keymap.set("n", "]c", function()

vim.keymap.set("n", maps.accept, function()

vim.keymap.set("n", maps.accept_all, function()

vim.keymap.set("n", maps.close, function()

vim.keymap.set("n", maps.reject, function()

vim.keymap.set({ "n", "v" }, maps.comment, function()

event = "User"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `setup(user_opts)`

- `accept_all()`

- `accept_file()`

- `next_hunk()`

- `prev_hunk()`

- `reject_request()`

- `start()`

- `stop()`


## References

- `opencode`

- `opencode.util`


_Generated in headless mode from static file analysis._
