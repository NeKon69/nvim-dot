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
require("luasnip")._active_update_dependents(p1)
require("luasnip")._api_do(p1, ...)
require("luasnip")._api_enter()
require("luasnip")._api_leave()
require("luasnip")._set_choice(p1, p2)
require("luasnip").activate_node(p1)
require("luasnip").active_update_dependents()
require("luasnip").add_snippets(p1, p2, p3)
require("luasnip").available(p1)
require("luasnip").change_choice(p1)
require("luasnip").choice_active()
require("luasnip").clean_invalidated(p1)
require("luasnip").cleanup()
require("luasnip").env_namespace(p1, p2)
require("luasnip").exit_out_of_region(p1)
require("luasnip").expand(p1)
require("luasnip").expand_auto()
require("luasnip").expand_or_jump()
require("luasnip").expand_or_jumpable()
require("luasnip").expand_or_locally_jumpable()
require("luasnip").expand_repeat()
require("luasnip").expandable()
require("luasnip").extend_decorator -- table
require("luasnip").extend_decorator.apply(p1, ...)
require("luasnip").extend_decorator.register(p1, ...)
require("luasnip").filetype_extend(p1, p2)
require("luasnip").filetype_set(p1, p2)
require("luasnip").get_active_snip()
require("luasnip").get_current_choices()
require("luasnip").get_id_snippet(p1)
require("luasnip").get_snip_env()
require("luasnip").get_snippet_filetypes()
require("luasnip").get_snippets(p1, p2)
require("luasnip").in_snippet()
require("luasnip").jump(p1)
require("luasnip").jump_destination(p1)
require("luasnip").jumpable(p1)
require("luasnip").load_snippet_docstrings(p1)
require("luasnip").locally_jumpable(p1)
require("luasnip").log -- table
require("luasnip").log.describe -- table
require("luasnip").log.describe.inspect(...)
require("luasnip").log.describe.node(...)
require("luasnip").log.describe.node_buftext(...)
require("luasnip").log.describe.traceback(...)
require("luasnip").log.log_location()
require("luasnip").log.new(p1)
require("luasnip").log.open()
require("luasnip").log.ping()
require("luasnip").log.set_loglevel(p1)
require("luasnip").log.time_fmt -- string
require("luasnip").lsp_expand(p1, p2)
require("luasnip").refresh_notify(p1)
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
require("luasnip").session.config.load_ft_func(p1)
require("luasnip").session.config.loaders_store_source -- boolean
require("luasnip").session.config.parser_nested_assembler(p1, p2)
require("luasnip").session.config.snip_env -- table
require("luasnip").session.config.update_events -- string
require("luasnip").session.current_nodes -- table
require("luasnip").session.ft_redirect -- table
require("luasnip").session.get_snip_env()
require("luasnip").session.jump_active -- boolean
require("luasnip").session.loaded_fts -- table
require("luasnip").session.ns_id -- number
require("luasnip").session.snippet_roots -- table
require("luasnip").set_choice(p1)
require("luasnip").setup(p1)
require("luasnip").setup_snip_env()
require("luasnip").snip_expand(p1, p2)
require("luasnip").store_snippet_docstrings(p1)
require("luasnip").unlink_current()
require("luasnip").unlink_current_if_deleted()
```

## Harder Calls (quick notes)

- `require("luasnip").add_snippets(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip")._set_choice(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").env_namespace(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").filetype_extend(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").filetype_set(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").get_snippets(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").lsp_expand(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("luasnip").session.config.parser_nested_assembler(p1, p2)`: setup entrypoint; call once and keep opts explicit.

## References

- Help: `:help luasnip` and `:help luasnip.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/LuaSnip/README.md`
- GitHub README: https://github.com/L3MON4D3/LuaSnip/blob/master/README.md

_Generated in headless mode with forced plugin load._
