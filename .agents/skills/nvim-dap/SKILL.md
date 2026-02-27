# Nvim-dap API Reference

This file is generated for plugin `mfussenegger/nvim-dap` and module `dap`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:DapClearBreakpoints
:DapContinue
:DapDisconnect
:DapEval
:DapNew
:DapPause
:DapRestartFrame
:DapSetLogLevel
:DapShowLog
:DapStepInto
:DapStepOut
:DapStepOver
:DapTerminate
:DapToggleBreakpoint
:DapToggleRepl
```

## Module API (`dap`)

```lua
require("dap") -- table
require("dap").ABORT -- table
require("dap")._tagfunc(p1, p2, p3)
require("dap").adapters -- table
require("dap").attach(p1, p2, p3)
require("dap").clear_breakpoints()
require("dap").close()
require("dap").configurations -- table
require("dap").continue(p1)
require("dap").defaults -- table
require("dap").defaults.fallback -- table
require("dap").defaults.fallback.auto_continue_if_many_stopped -- boolean
require("dap").defaults.fallback.exception_breakpoints -- string
require("dap").defaults.fallback.focus_terminal -- boolean
require("dap").defaults.fallback.stepping_granularity -- string
require("dap").defaults.fallback.terminal_win_cmd -- string
require("dap").disconnect(p1, p2)
require("dap").down()
require("dap").focus_frame()
require("dap").goto_(p1)
require("dap").launch(p1, p2, p3)
require("dap").list_breakpoints(p1)
require("dap").listeners -- table
require("dap").listeners.after -- table
require("dap").listeners.after.event_stopped -- table
require("dap").listeners.after.event_stopped.dap.sessions(p1)
require("dap").listeners.before -- table
require("dap").listeners.on_config -- table
require("dap").listeners.on_config.dap.expand_variable(p1)
require("dap").listeners.on_session -- table
require("dap").pause(p1)
require("dap").providers -- table
require("dap").providers.configs -- table
require("dap").providers.configs.dap.global(p1)
require("dap").providers.configs.dap.launch.json()
require("dap").repl -- table
require("dap").restart(p1, p2)
require("dap").restart_frame()
require("dap").reverse_continue(p1)
require("dap").run(p1, p2)
require("dap").run_last()
require("dap").run_to_cursor()
require("dap").session()
require("dap").sessions()
require("dap").set_breakpoint(p1, p2, p3)
require("dap").set_exception_breakpoints(p1, p2)
require("dap").set_log_level(p1)
require("dap").set_session(p1)
require("dap").status()
require("dap").step_back(p1)
require("dap").step_into(p1)
require("dap").step_out(p1)
require("dap").step_over(p1)
require("dap").stop()
require("dap").terminate(p1, p2, p3)
require("dap").toggle_breakpoint(p1, p2, p3, p4)
require("dap").up()
```

## Harder Calls (quick notes)

- `require("dap").toggle_breakpoint(p1, p2, p3, p4)`: UI/state entrypoint; verify window/buffer context before calling.
- `require("dap")._tagfunc(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("dap").attach(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("dap").launch(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("dap").set_breakpoint(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("dap").terminate(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("dap").disconnect(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("dap").restart(p1, p2)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help dap` and `:help dap.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-dap/README.md`
- GitHub README: https://github.com/mfussenegger/nvim-dap/blob/master/README.md

_Generated in headless mode with forced plugin load._
