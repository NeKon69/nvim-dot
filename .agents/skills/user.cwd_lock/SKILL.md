# User.cwd_lock API Reference

Source: `lua/user/cwd_lock.lua`

## File Behavior

- Maintains a locked working directory and blocks runtime cwd drift.
- Stores lock in memory and mirrors it to `vim.g.__nvim_locked_cwd`.
- Disables `autochdir`, initializes `user.project_index`, and seeds lock from startup dir.
- Provides Telescope-backed picker to set cwd from lock/cwd/start, indexed projects, extra top-level dirs, and recent files.

## Module API (`require("user.cwd_lock")`)

- `get()`: returns currently locked cwd or `nil`.
- `set(path)`: sets lock to `path` (or current cwd when empty) and changes cwd immediately.
- `setup()`: initializes locking/autocmds and defines `:CwdSet`, `:CwdShow`, `:CwdPick`.

## Commands

- `:CwdSet [path]`: set and lock cwd to argument or current cwd.
- `:CwdShow`: show currently locked cwd.
- `:CwdPick`: open interactive picker/input flow to choose and lock cwd.

## Keymaps, Events

- Keymaps: none defined in this module.
- `DirChanged`: enforces lock by restoring locked cwd if anything changes it.

## References

- `user.project_index`: project list and registration integration.
- `telescope.pickers`: picker UI.
- `telescope.finders`: table finder.
- `telescope.config`: sorter config.
- `telescope.actions` / `telescope.actions.state`: selection handling.
