# User.project_index API Reference

Source: `lua/user/project_index.lua`

## File Behavior

- Maintains project index cache at `stdpath("state")/project-index.json`.
- Considers directories containing `.nvim` as projects and maintains `.nvim/project_marker` display names.
- Performs one-time full scan for `.nvim` directories under `$HOME`, then marks cache as scanned.
- Keeps cache fresh on startup, directory changes, and marker file writes.

## Module API (`require("user.project_index")`)

- `register_project(path, opts)`: validates and indexes a project directory (optionally quiet).
- `get_projects()`: returns sorted live project list `{ path, name }` for existing indexed projects.
- `get_extra_top_level_dirs()`: returns sorted directories under `~/projects` and `~/CLionProjects`.
- `setup()`: loads cache, runs first scan, registers cwd, and installs index-maintenance autocmds.

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined in this module.
- `VimEnter`: indexes current cwd on startup.
- `DirChanged`: indexes new cwd after directory change.
- `BufWritePost` (pattern `project_marker`): re-indexes project when marker file changes.
