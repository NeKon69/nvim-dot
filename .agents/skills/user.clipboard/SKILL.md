# User.clipboard API Reference

Source: `lua/user/clipboard.lua`

## File Behavior

- Builds clipboard text as `<file="name">...</file="name">` using current buffer filename.
- Uses visual selection bounds when in visual mode; otherwise copies the full buffer.
- Writes output to the system clipboard register `+` and notifies copied line count.

## Module API (`require("user.clipboard")`)

- `copy_as_tag()`: copies selected/all buffer lines to clipboard in tagged file-block format.

## Commands, Keymaps, Events

- User commands: none defined in this module.
- Keymaps: none defined in this module.
- Autocmd events: none defined in this module.
