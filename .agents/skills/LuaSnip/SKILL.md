# LuaSnip API Reference

This file is generated for plugin `L3MON4D3/LuaSnip` and module `luasnip`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:LuaSnipListAvailable
:LuaSnipUnlinkCurrent
```

## Module API (`luasnip`)

```lua
require("luasnip") -- table
require("luasnip")._active_update_dependents(opts)
require("luasnip")._api_do(fn, ...)
require("luasnip")._api_enter()
require("luasnip")._api_leave()
require("luasnip")._set_choice(choice_indx, opts)
require("luasnip").activate_node(opts)
require("luasnip").active_update_dependents()
require("luasnip").add_snippets(ft, snippets, opts)
require("luasnip").available(snip_info)
require("luasnip").change_choice(val)
require("luasnip").choice_active()
require("luasnip").clean_invalidated(opts)
require("luasnip").cleanup()
require("luasnip").env_namespace(name, opts)
require("luasnip").exit_out_of_region(node)
require("luasnip").expand(opts)
require("luasnip").expand_auto()
require("luasnip").expand_or_jump()
require("luasnip").expand_or_jumpable()
require("luasnip").expand_or_locally_jumpable()
require("luasnip").expand_repeat()
require("luasnip").expandable()
require("luasnip").extend_decorator -- table
require("luasnip").extend_decorator.apply(fn, ...)
require("luasnip").extend_decorator.register(fn, ...)
require("luasnip").filetype_extend(ft, extend_fts)
require("luasnip").filetype_set(ft, extend_fts)
require("luasnip").get_active_snip()
require("luasnip").get_current_choices()
require("luasnip").get_id_snippet(id)
require("luasnip").get_snip_env()
require("luasnip").get_snippet_filetypes()
require("luasnip").get_snippets(ft, opts)
require("luasnip").in_snippet()
require("luasnip").jump(dir)
require("luasnip").jump_destination(dir)
require("luasnip").jumpable(dir)
require("luasnip").load_snippet_docstrings(snippet_table)
require("luasnip").locally_jumpable(dir)
require("luasnip").log -- table
require("luasnip").log.describe -- table
require("luasnip").log.describe.inspect(...)
require("luasnip").log.describe.node(...)
require("luasnip").log.describe.node_buftext(...)
require("luasnip").log.describe.traceback(...)
require("luasnip").log.log_location()
require("luasnip").log.new(module_name)
require("luasnip").log.open()
require("luasnip").log.ping()
require("luasnip").log.set_loglevel(target_level)
require("luasnip").log.time_fmt -- string
require("luasnip").lsp_expand(body, opts)
require("luasnip").refresh_notify(ft)
require("luasnip").session -- table
require("luasnip").session.active_choice_nodes -- table
require("luasnip").session.config -- table
require("luasnip").session.config.enable_autosnippets -- boolean
require("luasnip").session.config.exit_roots -- boolean
require("luasnip").session.config.ext_base_prio -- number
require("luasnip").session.config.ext_opts -- table
require("luasnip").session.config.ext_opts.1 -- table
require("luasnip").session.config.ext_opts.2 -- table
require("luasnip").session.config.ext_opts.3 -- table
require("luasnip").session.config.ext_opts.4 -- table
require("luasnip").session.config.ext_opts.5 -- table
require("luasnip").session.config.ext_opts.6 -- table
require("luasnip").session.config.ext_opts.7 -- table
require("luasnip").session.config.ext_opts.8 -- table
require("luasnip").session.config.ext_opts.9 -- table
require("luasnip").session.config.ext_prio_increase -- number
require("luasnip").session.config.ft_func()
require("luasnip").session.config.keep_roots -- boolean
require("luasnip").session.config.link_children -- boolean
require("luasnip").session.config.link_roots -- boolean
require("luasnip").session.config.load_ft_func(bufnr)
require("luasnip").session.config.loaders_store_source -- boolean
require("luasnip").session.config.parser_nested_assembler(pos, snip)
require("luasnip").session.config.snip_env -- table
require("luasnip").session.config.update_events -- string
require("luasnip").session.current_nodes -- table
require("luasnip").session.ft_redirect -- table
require("luasnip").session.get_snip_env()
require("luasnip").session.jump_active -- boolean
require("luasnip").session.loaded_fts -- table
require("luasnip").session.ns_id -- number
require("luasnip").session.snippet_roots -- table
require("luasnip").set_choice(choice_indx)
require("luasnip").setup(user_config)
require("luasnip").setup_snip_env()
require("luasnip").snip_expand(snippet, opts)
require("luasnip").store_snippet_docstrings(snippet_table)
require("luasnip").unlink_current()
require("luasnip").unlink_current_if_deleted()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help luasnip`, the local README, and the GitHub README listed below.

- `require("luasnip").add_snippets(ft, snippets, opts)`
- `require("luasnip")._set_choice(choice_indx, opts)`
- `require("luasnip").env_namespace(name, opts)`
- `require("luasnip").filetype_extend(ft, extend_fts)`
- `require("luasnip").filetype_set(ft, extend_fts)`
- `require("luasnip").get_snippets(ft, opts)`
- `require("luasnip").lsp_expand(body, opts)`
- `require("luasnip").session.config.parser_nested_assembler(pos, snip)`

## References

- Help: `:help luasnip` and `:help luasnip.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/LuaSnip/README.md`
- GitHub README: https://github.com/L3MON4D3/LuaSnip/blob/master/README.md

_Generated in headless mode with forced plugin load._
