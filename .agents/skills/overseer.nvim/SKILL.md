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
require("overseer").add_template_hook(p1, p2)
require("overseer").builtin -- table
require("overseer").builtin.jobstart(...)
require("overseer").builtin.system(p1, p2, p3)
require("overseer").clear_task_cache(p1)
require("overseer").close()
require("overseer").create_task_output_view(p1, p2)
require("overseer").enable_dap(p1)
require("overseer").get_all_commands()
require("overseer").get_all_highlights()
require("overseer").list_tasks(p1)
require("overseer").new_task(p1)
require("overseer").open(p1)
require("overseer").preload_task_cache(p1, p2)
require("overseer").private_setup()
require("overseer").register_alias(p1, p2, p3)
require("overseer").register_template(p1)
require("overseer").remove_template_hook(p1, p2)
require("overseer").run_action(p1, p2)
require("overseer").run_task(p1, p2)
require("overseer").run_template(p1, p2)
require("overseer").setup(p1)
require("overseer").toggle(p1)
require("overseer").wrap_builtins(p1)
```

## Harder Calls (quick notes)

- `require("overseer").builtin.system(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").register_alias(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").add_template_hook(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").create_task_output_view(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").preload_task_cache(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").remove_template_hook(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("overseer").run_action(p1, p2)`: side-effecting call; validate inputs and error paths.
- `require("overseer").run_task(p1, p2)`: side-effecting call; validate inputs and error paths.

## References

- Help: `:help overseer` and `:help overseer.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/overseer.nvim/README.md`
- GitHub README: https://github.com/stevearc/overseer.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
