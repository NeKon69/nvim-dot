# Overseer.nvim API Reference

This file is generated for plugin `stevearc/overseer.nvim` and module `overseer`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:OverseerClose
:OverseerOpen
:OverseerRun
:OverseerShell
:OverseerTaskAction
:OverseerToggle
```

## Module API (`overseer`)

```lua
require("overseer") -- table
require("overseer").add_template_hook(opts, hook)
require("overseer").builtin -- table
require("overseer").builtin.jobstart(...)
require("overseer").builtin.system(arg1, arg2, arg3)
require("overseer").clear_task_cache(opts)
require("overseer").close()
require("overseer").create_task_output_view(winid, opts)
require("overseer").enable_dap(enabled)
require("overseer").get_all_commands()
require("overseer").get_all_highlights()
require("overseer").list_tasks(opts)
require("overseer").new_task(opts)
require("overseer").open(opts)
require("overseer").preload_task_cache(opts, cb)
require("overseer").private_setup()
require("overseer").register_alias(name, components, override)
require("overseer").register_template(defn)
require("overseer").remove_template_hook(opts, hook)
require("overseer").run_action(task, name)
require("overseer").run_task(opts, callback)
require("overseer").run_template(opts, callback)
require("overseer").setup(opts)
require("overseer").toggle(opts)
require("overseer").wrap_builtins(enabled)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help overseer`, the local README, and the GitHub README listed below.

- `require("overseer").builtin.system(arg1, arg2, arg3)`
- `require("overseer").register_alias(name, components, override)`
- `require("overseer").add_template_hook(opts, hook)`
- `require("overseer").create_task_output_view(winid, opts)`
- `require("overseer").preload_task_cache(opts, cb)`
- `require("overseer").remove_template_hook(opts, hook)`
- `require("overseer").run_action(task, name)`
- `require("overseer").run_task(opts, callback)`

## References

- Help: `:help overseer` and `:help overseer.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/overseer.nvim/README.md`
- GitHub README: https://github.com/stevearc/overseer.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
