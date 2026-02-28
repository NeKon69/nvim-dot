# User.project_root API Reference

Source: `lua/user/project_root.lua`

## File Behavior

- `marker_names`: root markers checked upward (`.git`, `.nvim-root`, `justfile`, `package.json`, `pyproject.toml`, `Cargo.toml`, `go.mod`, `Makefile`, `CMakeLists.txt`).
- `state.startup_dir`: captured once at load from `vim.g.__nvim_startup_dir`, then `$PWD`, then `getcwd()`, normalized to a real directory.
- `state.override_dir`: optional runtime override; when set, `resolve()` returns it directly.
- `trim_trailing_slash(path)`: keeps `/` and `X:/` intact, strips trailing `/` for stable comparisons.
- `normalize_dir(path)`: canonicalizes input path, resolves files to parent dir, and returns `nil` for non-existent paths.
- `marker_root_for(start_dir, names)`: searches upward with `vim.fs.find(...)` and returns normalized marker parent.
- `detect_startup_dir()`: selects and normalizes startup anchor directory in priority order.

## Module API (`require("user.project_root")`)

- `startup_dir()`: returns cached startup directory captured at module load.
- `set_override(path)`: sets override directory from `path`; returns `true` on success or `false, "invalid directory"` when invalid.
- `clear_override()`: clears manual override so resolution falls back to startup/marker logic.
- `override_dir()`: returns current override directory or `nil`.
- `resolve()`: resolves project root in order `override -> startup/current cwd -> git root -> marker root -> anchor`.

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined in this module.
- Autocmd events: none defined in this module.
