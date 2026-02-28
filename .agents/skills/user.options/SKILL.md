# User.options API Reference

Source: `lua/user/options.lua`

## File Behavior

- Sets base editor options (clipboard, search, indentation, UI, undo, message behavior).
- Sets `mapleader`/`maplocalleader` to space.
- Disables built-in `netrw`/`netrwPlugin` to avoid conflicts with external file tree plugins.
- Creates `FileExplorer` augroup and keeps `autochdir = false` for stable cwd behavior.

## Module API (`user.options`)

- Exported module functions: none (this file configures `vim.opt`/globals directly on load).

## Commands, Keymaps, Events

- User commands: none defined.
- Keymaps: none defined.
- Autocmd events: none defined in this file.
