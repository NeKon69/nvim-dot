# Plugin.dap API Reference

This file is generated for source `lua/plugins/dap.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`plugins.dap`)

```lua
vim.keymap.set("n", "<leader>bD", debug_current_file, { desc = "Debug Current File" })

vim.keymap.set("n", "<leader>dB", pb_set_conditional_breakpoint, { desc = "DAP: Conditional Breakpoint" })

vim.keymap.set("n", "<leader>db", pb_toggle_breakpoint, { desc = "DAP: Toggle Breakpoint" })

vim.keymap.set("n", "<leader>dd", smart_dap_toggle, { desc = "DAP: Smart Toggle/Start" })

vim.keymap.set("n", "<leader>dk", terminate_debug_session, { desc = "DAP: Terminate" })

vim.keymap.set("n", "<leader>do", function()

vim.keymap.set("n", key, val[1], { desc = val[2] })

event = "BufWritePost"

event = "DirChanged"

event = "VimEnter"

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

_No exported function signatures detected._

## References

- `Jorenar/nvim-dap-disasm`

- `Weissle/persistent-breakpoints.nvim` (skill: `.agents/skills/persistent-breakpoints.nvim/SKILL.md`)

- `dap`

- `dap-disasm`

- `dap-view`

- `dap.breakpoints`

- `dap.utils`

- `igorlfs/nvim-dap-view`

- `jay-babu/mason-nvim-dap.nvim`

- `lualine` (skill: `.agents/skills/lualine.nvim/SKILL.md`)

- `mason-nvim-dap`

- `mfussenegger/nvim-dap` (skill: `.agents/skills/nvim-dap/SKILL.md`)

- `nvim-dap-virtual-text`

- `overseer` (skill: `.agents/skills/overseer.nvim/SKILL.md`)

- `persistent-breakpoints` (skill: `.agents/skills/persistent-breakpoints.nvim/SKILL.md`)

- `persistent-breakpoints.api`

- `persistent-breakpoints.config`

- `persistent-breakpoints.inmemory`

- `persistent-breakpoints.utils`

- `stevearc/overseer.nvim` (skill: `.agents/skills/overseer.nvim/SKILL.md`)

- `thehamsta/nvim-dap-virtual-text`


_Generated in headless mode from static file analysis._
