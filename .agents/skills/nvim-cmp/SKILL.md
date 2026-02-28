# Nvim-cmp API Reference

This file is generated for plugin `hrsh7th/nvim-cmp` and module `cmp`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:CmpStatus
```

## Module API (`cmp`)

```lua
require("cmp") -- table
require("cmp").ConfirmBehavior -- table
require("cmp").ConfirmBehavior.Insert -- string
require("cmp").ConfirmBehavior.Replace -- string
require("cmp").ContextReason -- table
require("cmp").ContextReason.Auto -- string
require("cmp").ContextReason.Manual -- string
require("cmp").ContextReason.None -- string
require("cmp").ContextReason.TriggerOnly -- string
require("cmp").ItemField -- table
require("cmp").ItemField.Abbr -- string
require("cmp").ItemField.Icon -- string
require("cmp").ItemField.Kind -- string
require("cmp").ItemField.Menu -- string
require("cmp").PreselectMode -- table
require("cmp").PreselectMode.Item -- string
require("cmp").PreselectMode.None -- string
require("cmp").SelectBehavior -- table
require("cmp").SelectBehavior.Insert -- string
require("cmp").SelectBehavior.Select -- string
require("cmp").TriggerEvent -- table
require("cmp").TriggerEvent.InsertEnter -- string
require("cmp").TriggerEvent.TextChanged -- string
require("cmp").abort(...)
require("cmp").close(...)
require("cmp").close_docs(...)
require("cmp").complete(...)
require("cmp").complete_common_string(...)
require("cmp").config -- table
require("cmp").config.compare -- table
require("cmp").config.compare.exact(entry1, entry2)
require("cmp").config.compare.kind(entry1, entry2)
require("cmp").config.compare.length(entry1, entry2)
require("cmp").config.compare.locality -- table
require("cmp").config.compare.locality.lines_cache -- table
require("cmp").config.compare.locality.lines_count -- number
require("cmp").config.compare.locality.locality_map -- table
require("cmp").config.compare.locality.update(self)
require("cmp").config.compare.offset(entry1, entry2)
require("cmp").config.compare.order(entry1, entry2)
require("cmp").config.compare.recently_used -- table
require("cmp").config.compare.recently_used.add_entry(self, e)
require("cmp").config.compare.recently_used.records -- table
require("cmp").config.compare.scopes -- table
require("cmp").config.compare.scopes.scopes_map -- table
require("cmp").config.compare.scopes.update(self)
require("cmp").config.compare.score(entry1, entry2)
require("cmp").config.compare.sort_text(entry1, entry2)
require("cmp").config.disable -- userdata
require("cmp").config.mapping -- table
require("cmp").config.mapping.abort()
require("cmp").config.mapping.close()
require("cmp").config.mapping.close_docs()
require("cmp").config.mapping.complete(option)
require("cmp").config.mapping.complete_common_string()
require("cmp").config.mapping.confirm(option)
require("cmp").config.mapping.open_docs()
require("cmp").config.mapping.preset -- table
require("cmp").config.mapping.preset.cmdline(override)
require("cmp").config.mapping.preset.insert(override)
require("cmp").config.mapping.scroll_docs(delta)
require("cmp").config.mapping.select_next_item(option)
require("cmp").config.mapping.select_prev_item(option)
require("cmp").config.sources(...)
require("cmp").config.window -- table
require("cmp").config.window.bordered(opts)
require("cmp").config.window.get_border()
require("cmp").confirm(...)
require("cmp").core -- table
require("cmp").core.context -- table
require("cmp").core.context.aborted -- boolean
require("cmp").core.context.bufnr -- number
require("cmp").core.context.cache -- table
require("cmp").core.context.cache.entries -- table
require("cmp").core.context.cursor -- table
require("cmp").core.context.cursor.character -- number
require("cmp").core.context.cursor.col -- number
require("cmp").core.context.cursor.line -- number
require("cmp").core.context.cursor.row -- number
require("cmp").core.context.cursor_after_line -- string
require("cmp").core.context.cursor_before_line -- string
require("cmp").core.context.cursor_line -- string
require("cmp").core.context.filetype -- string
require("cmp").core.context.id -- number
require("cmp").core.context.option -- table
require("cmp").core.context.prev_context -- table
require("cmp").core.context.prev_context.aborted -- boolean
require("cmp").core.context.prev_context.bufnr -- number
require("cmp").core.context.prev_context.cache -- table
require("cmp").core.context.prev_context.cursor -- table
require("cmp").core.context.prev_context.cursor_after_line -- string
require("cmp").core.context.prev_context.cursor_before_line -- string
require("cmp").core.context.prev_context.cursor_line -- string
require("cmp").core.context.prev_context.filetype -- string
require("cmp").core.context.prev_context.id -- number
require("cmp").core.context.prev_context.input -- string
require("cmp").core.context.prev_context.option -- table
require("cmp").core.context.prev_context.prev_context -- table
require("cmp").core.context.prev_context.time -- number
require("cmp").core.context.time -- number
require("cmp").core.event -- table
require("cmp").core.event.events -- table
require("cmp").core.event.events.complete_done -- table
require("cmp").core.event.events.confirm_done -- table
require("cmp").core.sources -- table
require("cmp").core.suspending -- boolean
require("cmp").core.view -- table
require("cmp").core.view.custom_entries_view -- table
require("cmp").core.view.custom_entries_view.active -- boolean
require("cmp").core.view.custom_entries_view.bottom_up -- boolean
require("cmp").core.view.custom_entries_view.entries -- table
require("cmp").core.view.custom_entries_view.entries_win -- table
require("cmp").core.view.custom_entries_view.event -- table
require("cmp").core.view.custom_entries_view.offset -- number
require("cmp").core.view.docs_view -- table
require("cmp").core.view.docs_view.window -- table
require("cmp").core.view.event -- table
require("cmp").core.view.event.events -- table
require("cmp").core.view.ghost_text_view -- table
require("cmp").core.view.is_docs_view_pinned -- boolean
require("cmp").core.view.native_entries_view -- table
require("cmp").core.view.native_entries_view.entries -- table
require("cmp").core.view.native_entries_view.event -- table
require("cmp").core.view.native_entries_view.items -- table
require("cmp").core.view.native_entries_view.offset -- number
require("cmp").core.view.native_entries_view.preselect_index -- number
require("cmp").core.view.resolve_dedup(callback)
require("cmp").core.view.wildmenu_entries_view -- table
require("cmp").core.view.wildmenu_entries_view.active -- boolean
require("cmp").core.view.wildmenu_entries_view.entries -- table
require("cmp").core.view.wildmenu_entries_view.entries_win -- table
require("cmp").core.view.wildmenu_entries_view.event -- table
require("cmp").core.view.wildmenu_entries_view.offset -- number
require("cmp").core.view.wildmenu_entries_view.offsets -- table
require("cmp").core.view.wildmenu_entries_view.selected_index -- number
require("cmp").get_active_entry(...)
require("cmp").get_config()
require("cmp").get_entries(...)
require("cmp").get_registered_sources()
require("cmp").get_selected_entry(...)
require("cmp").get_selected_index(...)
require("cmp").lsp -- table
require("cmp").lsp.CompletionItemKind -- table
require("cmp").lsp.CompletionItemKind.1 -- string
require("cmp").lsp.CompletionItemKind.10 -- string
require("cmp").lsp.CompletionItemKind.11 -- string
require("cmp").lsp.CompletionItemKind.12 -- string
require("cmp").lsp.CompletionItemKind.13 -- string
require("cmp").lsp.CompletionItemKind.14 -- string
require("cmp").lsp.CompletionItemKind.15 -- string
require("cmp").lsp.CompletionItemKind.16 -- string
require("cmp").lsp.CompletionItemKind.17 -- string
require("cmp").lsp.CompletionItemKind.18 -- string
require("cmp").lsp.CompletionItemKind.19 -- string
require("cmp").lsp.CompletionItemKind.2 -- string
require("cmp").lsp.CompletionItemKind.20 -- string
require("cmp").lsp.CompletionItemKind.21 -- string
require("cmp").lsp.CompletionItemKind.22 -- string
require("cmp").lsp.CompletionItemKind.23 -- string
require("cmp").lsp.CompletionItemKind.24 -- string
require("cmp").lsp.CompletionItemKind.25 -- string
require("cmp").lsp.CompletionItemKind.3 -- string
require("cmp").lsp.CompletionItemKind.4 -- string
require("cmp").lsp.CompletionItemKind.5 -- string
require("cmp").lsp.CompletionItemKind.6 -- string
require("cmp").lsp.CompletionItemKind.7 -- string
require("cmp").lsp.CompletionItemKind.8 -- string
require("cmp").lsp.CompletionItemKind.9 -- string
require("cmp").lsp.CompletionItemKind.Class -- number
require("cmp").lsp.CompletionItemKind.Color -- number
require("cmp").lsp.CompletionItemKind.Constant -- number
require("cmp").lsp.CompletionItemKind.Constructor -- number
require("cmp").lsp.CompletionItemKind.Enum -- number
require("cmp").lsp.CompletionItemKind.EnumMember -- number
require("cmp").lsp.CompletionItemKind.Event -- number
require("cmp").lsp.CompletionItemKind.Field -- number
require("cmp").lsp.CompletionItemKind.File -- number
require("cmp").lsp.CompletionItemKind.Folder -- number
require("cmp").lsp.CompletionItemKind.Function -- number
require("cmp").lsp.CompletionItemKind.Interface -- number
require("cmp").lsp.CompletionItemKind.Keyword -- number
require("cmp").lsp.CompletionItemKind.Method -- number
require("cmp").lsp.CompletionItemKind.Module -- number
require("cmp").lsp.CompletionItemKind.Operator -- number
require("cmp").lsp.CompletionItemKind.Property -- number
require("cmp").lsp.CompletionItemKind.Reference -- number
require("cmp").lsp.CompletionItemKind.Snippet -- number
require("cmp").lsp.CompletionItemKind.Struct -- number
require("cmp").lsp.CompletionItemKind.Text -- number
require("cmp").lsp.CompletionItemKind.TypeParameter -- number
require("cmp").lsp.CompletionItemKind.Unit -- number
require("cmp").lsp.CompletionItemKind.Value -- number
require("cmp").lsp.CompletionItemKind.Variable -- number
require("cmp").lsp.CompletionItemTag -- table
require("cmp").lsp.CompletionItemTag.Deprecated -- number
require("cmp").lsp.CompletionTriggerKind -- table
require("cmp").lsp.CompletionTriggerKind.Invoked -- number
require("cmp").lsp.CompletionTriggerKind.TriggerCharacter -- number
require("cmp").lsp.CompletionTriggerKind.TriggerForIncompleteCompletions -- number
require("cmp").lsp.InsertTextFormat -- table
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help cmp`, the local README, and the GitHub README listed below.

- `require("cmp").config.compare.exact(entry1, entry2)`
- `require("cmp").config.compare.kind(entry1, entry2)`
- `require("cmp").config.compare.length(entry1, entry2)`
- `require("cmp").config.compare.offset(entry1, entry2)`
- `require("cmp").config.compare.order(entry1, entry2)`
- `require("cmp").config.compare.recently_used.add_entry(self, e)`
- `require("cmp").config.compare.score(entry1, entry2)`
- `require("cmp").config.compare.sort_text(entry1, entry2)`

## References

- Help: `:help cmp` and `:help cmp.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-cmp/README.md`
- GitHub README: https://github.com/hrsh7th/nvim-cmp/blob/master/README.md

_Generated in headless mode with forced plugin load._
