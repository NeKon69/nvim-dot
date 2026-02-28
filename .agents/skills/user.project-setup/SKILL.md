# User.project-setup API Reference

Source: `lua/user/project-setup.lua`

## File Behavior

- Ensures user template directory exists at `stdpath("config")/templates/overseer`.
- On project-entry events, creates `justfile` from first matching `*.just` template when cwd has no `justfile`.
- Supports template markers via `# @markers:` header; falls back to template basename as marker.
- After creating a `justfile`, clears Overseer cache and refreshes `_G.BuildSystem` metadata if available.

## Module API (`require("user.project-setup")`)

- `setup()`: installs autocmd automation that generates a project `justfile` from templates.

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined in this module.
- `VimEnter`: checks cwd for missing `justfile` and attempts template-based generation.
- `DirChanged`: reruns the same generation logic after directory switches.

## References

- `overseer`: used to clear task cache after file generation.
