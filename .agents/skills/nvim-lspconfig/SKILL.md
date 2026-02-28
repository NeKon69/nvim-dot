# Nvim-lspconfig API Reference

This file is generated for plugin `neovim/nvim-lspconfig` and module `lspconfig`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lspconfig`)

```lua
require("lspconfig") -- table
require("lspconfig").server_aliases(name)
require("lspconfig").util -- table
require("lspconfig").util._parse_user_command_options(command_definition)
require("lspconfig").util.add_hook_after(func, new_fn)
require("lspconfig").util.add_hook_before(func, new_fn)
require("lspconfig").util.available_servers()
require("lspconfig").util.bufname_valid(bufname)
require("lspconfig").util.create_module_commands(module_name, commands)
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
require("lspconfig").util.find_git_ancestor(startpath)
require("lspconfig").util.find_mercurial_ancestor(startpath)
require("lspconfig").util.find_node_modules_ancestor(startpath)
require("lspconfig").util.find_package_json_ancestor(startpath)
require("lspconfig").util.get_active_client_by_name(bufnr, servername)
require("lspconfig").util.get_active_clients_list_by_ft(filetype)
require("lspconfig").util.get_config_by_ft(filetype)
require("lspconfig").util.get_lsp_clients(filter)
require("lspconfig").util.get_managed_clients()
require("lspconfig").util.get_other_matching_providers(filetype)
require("lspconfig").util.get_typescript_server_path(root_dir)
require("lspconfig").util.insert_package_json(root_files, field, fname)
require("lspconfig").util.path -- table
require("lspconfig").util.path.dirname(arg1)
require("lspconfig").util.path.exists(filename)
require("lspconfig").util.path.is_descendant(root, path)
require("lspconfig").util.path.is_dir(filename)
require("lspconfig").util.path.is_file(path)
require("lspconfig").util.path.iterate_parents(arg1)
require("lspconfig").util.path.join(...)
require("lspconfig").util.path.path_separator -- string
require("lspconfig").util.path.sanitize(arg1, arg2)
require("lspconfig").util.root_markers_with_field(root_files, new_names, field, fname)
require("lspconfig").util.root_pattern(...)
require("lspconfig").util.search_ancestors(startpath, func)
require("lspconfig").util.strip_archive_subpath(path)
require("lspconfig").util.tbl_flatten(t)
require("lspconfig").util.validate_bufnr(bufnr)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help lspconfig`, the local README, and the GitHub README listed below.

- `require("lspconfig").util.root_markers_with_field(root_files, new_names, field, fname)`
- `require("lspconfig").util.insert_package_json(root_files, field, fname)`
- `require("lspconfig").util.add_hook_after(func, new_fn)`
- `require("lspconfig").util.add_hook_before(func, new_fn)`
- `require("lspconfig").util.create_module_commands(module_name, commands)`
- `require("lspconfig").util.get_active_client_by_name(bufnr, servername)`
- `require("lspconfig").util.path.is_descendant(root, path)`
- `require("lspconfig").util.path.sanitize(arg1, arg2)`

## References

- Help: `:help lspconfig` and `:help lspconfig.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-lspconfig/README.md`
- GitHub README: https://github.com/neovim/nvim-lspconfig/blob/master/README.md

_Generated in headless mode with forced plugin load._
