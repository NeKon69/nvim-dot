# Nvim-lspconfig API Reference

This file is generated for plugin `neovim/nvim-lspconfig` and module `lspconfig`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lspconfig`)

```lua
require("lspconfig") -- table
require("lspconfig").server_aliases(p1)
require("lspconfig").util -- table
require("lspconfig").util._parse_user_command_options(p1)
require("lspconfig").util.add_hook_after(p1, p2)
require("lspconfig").util.add_hook_before(p1, p2)
require("lspconfig").util.available_servers()
require("lspconfig").util.bufname_valid(p1)
require("lspconfig").util.create_module_commands(p1, p2)
require("lspconfig").util.default_config -- table
require("lspconfig").util.default_config.autostart -- boolean
require("lspconfig").util.default_config.capabilities -- table
require("lspconfig").util.default_config.capabilities.general -- table
require("lspconfig").util.default_config.capabilities.textDocument -- table
require("lspconfig").util.default_config.capabilities.window -- table
require("lspconfig").util.default_config.capabilities.workspace -- table
require("lspconfig").util.default_config.handlers -- table
require("lspconfig").util.default_config.init_options -- table
require("lspconfig").util.default_config.log_level -- number
require("lspconfig").util.default_config.message_level -- number
require("lspconfig").util.default_config.settings -- table
require("lspconfig").util.find_git_ancestor(p1)
require("lspconfig").util.find_mercurial_ancestor(p1)
require("lspconfig").util.find_node_modules_ancestor(p1)
require("lspconfig").util.find_package_json_ancestor(p1)
require("lspconfig").util.get_active_client_by_name(p1, p2)
require("lspconfig").util.get_active_clients_list_by_ft(p1)
require("lspconfig").util.get_config_by_ft(p1)
require("lspconfig").util.get_lsp_clients(p1)
require("lspconfig").util.get_managed_clients()
require("lspconfig").util.get_other_matching_providers(p1)
require("lspconfig").util.get_typescript_server_path(p1)
require("lspconfig").util.insert_package_json(p1, p2, p3)
require("lspconfig").util.path -- table
require("lspconfig").util.path.dirname(p1)
require("lspconfig").util.path.exists(p1)
require("lspconfig").util.path.is_descendant(p1, p2)
require("lspconfig").util.path.is_dir(p1)
require("lspconfig").util.path.is_file(p1)
require("lspconfig").util.path.iterate_parents(p1)
require("lspconfig").util.path.join(...)
require("lspconfig").util.path.path_separator -- string
require("lspconfig").util.path.sanitize(p1, p2)
require("lspconfig").util.root_markers_with_field(p1, p2, p3, p4)
require("lspconfig").util.root_pattern(...)
require("lspconfig").util.search_ancestors(p1, p2)
require("lspconfig").util.strip_archive_subpath(p1)
require("lspconfig").util.tbl_flatten(p1)
require("lspconfig").util.validate_bufnr(p1)
```

## Harder Calls (quick notes)

- `require("lspconfig").util.root_markers_with_field(p1, p2, p3, p4)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.insert_package_json(p1, p2, p3)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.add_hook_after(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.add_hook_before(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.create_module_commands(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.get_active_client_by_name(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.path.is_descendant(p1, p2)`: setup entrypoint; call once and keep opts explicit.
- `require("lspconfig").util.path.sanitize(p1, p2)`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help lspconfig` and `:help lspconfig.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-lspconfig/README.md`
- GitHub README: https://github.com/neovim/nvim-lspconfig/blob/master/README.md

_Generated in headless mode with forced plugin load._
