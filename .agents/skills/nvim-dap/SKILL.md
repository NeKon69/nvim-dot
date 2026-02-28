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
require("dap")._tagfunc(_, flags, _)
require("dap").adapters -- table
require("dap").attach(adapter, config, opts)
require("dap").clear_breakpoints()
require("dap").close()
require("dap").configurations -- table
require("dap").continue(opts)
require("dap").defaults -- table
require("dap").defaults.fallback -- table
require("dap").defaults.fallback.auto_continue_if_many_stopped -- boolean
require("dap").defaults.fallback.exception_breakpoints -- string
require("dap").defaults.fallback.focus_terminal -- boolean
require("dap").defaults.fallback.stepping_granularity -- string
require("dap").defaults.fallback.terminal_win_cmd -- string
require("dap").disconnect(opts, cb)
require("dap").down()
require("dap").focus_frame()
require("dap").goto_(line)
require("dap").launch(adapter, config, opts)
require("dap").list_breakpoints(openqf)
require("dap").listeners -- table
require("dap").listeners.after -- table
require("dap").listeners.after.event_stopped -- table
require("dap").listeners.after.event_stopped.dap.sessions(s)
require("dap").listeners.before -- table
require("dap").listeners.on_config -- table
require("dap").listeners.on_config.dap.expand_variable(config)
require("dap").listeners.on_session -- table
require("dap").pause(thread_id)
require("dap").providers -- table
require("dap").providers.configs -- table
require("dap").providers.configs.dap.global(bufnr)
require("dap").providers.configs.dap.launch.json()
require("dap").repl -- table
require("dap").restart(config, opts)
require("dap").restart_frame()
require("dap").reverse_continue(opts)
require("dap").run(config, opts)
require("dap").run_last()
require("dap").run_to_cursor()
require("dap").session()
require("dap").sessions()
require("dap").set_breakpoint(condition, hit_condition, log_message)
require("dap").set_exception_breakpoints(filters, exceptionOptions)
require("dap").set_log_level(level)
require("dap").set_session(new_session)
require("dap").status()
require("dap").step_back(opts)
require("dap").step_into(opts)
require("dap").step_out(opts)
require("dap").step_over(opts)
require("dap").stop()
require("dap").terminate(opts, disconnect_opts, cb)
require("dap").toggle_breakpoint(condition, hit_condition, log_message, replace_old)
require("dap").up()
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help dap`, the local README, and the GitHub README listed below.

- `require("dap").toggle_breakpoint(condition, hit_condition, log_message, replace_old)`
- `require("dap")._tagfunc(_, flags, _)`
- `require("dap").attach(adapter, config, opts)`
- `require("dap").launch(adapter, config, opts)`
- `require("dap").set_breakpoint(condition, hit_condition, log_message)`
- `require("dap").terminate(opts, disconnect_opts, cb)`
- `require("dap").disconnect(opts, cb)`
- `require("dap").restart(config, opts)`

## References

- Help: `:help dap` and `:help dap.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-dap/README.md`
- GitHub README: https://github.com/mfussenegger/nvim-dap/blob/master/README.md

_Generated in headless mode with forced plugin load._
