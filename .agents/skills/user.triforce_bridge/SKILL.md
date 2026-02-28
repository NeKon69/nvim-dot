# User.triforce_bridge API Reference

Source: `lua/user/triforce_bridge.lua`

## File Behavior

- Maintains `_G.TriforceExtra` counters for usage telemetry (telescope, harpoon, debug, commands, saves, etc.).
- Loads persisted counters from `stdpath("data")/triforce_extra.json` on startup.
- Saves counters periodically (60s timer) and again on `VimLeavePre`.
- Uses autocmd hooks plus `vim.on_key` to increment specific counters.

## Module API (`user.triforce_bridge`)

- Exported module functions: none (file behavior is side-effect driven).

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined; uses `vim.on_key` to count normal-mode undo key presses (`u`).
- `User` pattern `TelescopeFindPre`: increments `telescope_opened`.
- `FileType` pattern `harpoon`: increments `harpoon_switches`.
- `FileType` pattern `OverseerOutput`: increments `compilations`.
- `FileType` pattern `dap-repl`: increments `dap_sessions`.
- `TermOpen`: increments `term_opens`.
- `BufReadPost` pattern `*.cu,*.cuh`: increments `cuda_files_touched`.
- `FileType` pattern `gitcommit`: increments `git_commits`.
- `CmdlineLeave`: increments `total_commands` for completed commands and also `compilations` for `Overseer*`/`make`/`CMake`.
- `BufWritePost`: increments `saves_count`.
- `VimLeavePre`: persists counters to disk.
