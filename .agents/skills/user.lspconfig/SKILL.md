# User.lspconfig API Reference

Source: `lua/user/lspconfig.lua`

## File Behavior

- Builds enhanced LSP capabilities from `cmp_nvim_lsp` (snippet + resolve support).
- Clears LSP log file on startup and configures diagnostics/floating window defaults.
- Installs per-buffer LSP keymaps and feature autocmds on `LspAttach`.
- Implements delayed auto-hover with content checks to avoid noisy/empty popups.

## Module API (`require("user.lspconfig")`)

- `capabilities`: prebuilt LSP client capabilities table for server setup.

## Keymaps (set on `LspAttach`)

- `<M-CR>`: Lspsaga code action.
- `gd`: go to definition (history-wrapped).
- `gp`: peek definition (history-wrapped).
- `gD`: go to declaration (history-wrapped).
- `gi`: go to implementation (history-wrapped).
- `gt`: go to type definition (history-wrapped).
- `gh`: open finder (history-wrapped).
- `K`: manual hover popup.
- `<leader>ca`: code action.
- `<leader>cr`: rename symbol.
- `<leader>o`: symbol outline.
- `<leader>ci`: incoming calls.
- `<leader>co`: outgoing calls.
- `<leader>fm`: async format buffer.
- `<leader>cl`: run CodeLens (only when server supports CodeLens).

## Commands, Events

- User commands: none defined in this module.
- `LspAttach`: installs keymaps and buffer-local LSP behavior.
- `BufEnter` / `CursorHold` / `InsertLeave`: refresh CodeLens when supported.
- `CursorHold` / `CursorHoldI`: trigger document highlights or delayed hover flow.
- `CursorMoved`: clear highlights and cancel hover timer.
- `InsertEnter`: cancel hover timer while entering insert mode.

## References

- `cmp_nvim_lsp`: LSP capabilities integration.
- `lspsaga.hover`: hover window state checks.
- `textDocument/hover`: low-level hover request used by delayed auto-hover.
