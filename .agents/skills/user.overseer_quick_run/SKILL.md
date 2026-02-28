# User.overseer_quick_run API Reference

Source: `lua/user/overseer_quick_run.lua`

## File Behavior

- Exports a plain extension-to-command template table for quick run/build commands.
- Placeholders expected by callers: `{file}` (source path) and `{bin}` (output/executable path base).
- Intended for consumer modules that render and execute command templates.

## Module API (`require("user.overseer_quick_run")`)

- `cpp`: `clang++ -std=c++20 -O3 {file} -o {bin} && {bin}`.
- `py`: `python3 {file}`.
- `asm`: `nasm -f elf64 {file} -o {bin}.o && ld {bin}.o -o {bin} && {bin}`.

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined in this module.
- Autocmd events: none defined in this module.
