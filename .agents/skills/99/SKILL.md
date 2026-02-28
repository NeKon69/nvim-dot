# 99 API Reference

This file is generated for plugin `ThePrimeagen/99` and module `99`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`99`)

```lua
require("99") -- table
require("99").DEBUG -- number
require("99").ERROR -- number
require("99").Extensions -- table
require("99").Extensions.Worker -- table
require("99").Extensions.Worker.craft_prompt(worker)
require("99").Extensions.Worker.search()
require("99").Extensions.Worker.set_work(opts)
require("99").Extensions.Worker.update_work()
require("99").FATAL -- number
require("99").INFO -- number
require("99").Providers -- table
require("99").Providers.BaseProvider -- table
require("99").Providers.BaseProvider._retrieve_response(self, context)
require("99").Providers.BaseProvider.fetch_models(callback)
require("99").Providers.BaseProvider.make_request(self, query, context, observer)
require("99").Providers.ClaudeCodeProvider -- table
require("99").Providers.ClaudeCodeProvider._build_command(_, query, context)
require("99").Providers.ClaudeCodeProvider._get_default_model()
require("99").Providers.ClaudeCodeProvider._get_provider_name()
require("99").Providers.ClaudeCodeProvider.fetch_models(callback)
require("99").Providers.CursorAgentProvider -- table
require("99").Providers.CursorAgentProvider._build_command(_, query, context)
require("99").Providers.CursorAgentProvider._get_default_model()
require("99").Providers.CursorAgentProvider._get_provider_name()
require("99").Providers.CursorAgentProvider.fetch_models(callback)
require("99").Providers.GeminiCLIProvider -- table
require("99").Providers.GeminiCLIProvider._build_command(_, query, context)
require("99").Providers.GeminiCLIProvider._get_default_model()
require("99").Providers.GeminiCLIProvider._get_provider_name()
require("99").Providers.KiroProvider -- table
require("99").Providers.KiroProvider._build_command(_, query, context)
require("99").Providers.KiroProvider._get_default_model()
require("99").Providers.KiroProvider._get_provider_name()
require("99").Providers.OpenCodeProvider -- table
require("99").Providers.OpenCodeProvider._build_command(_, query, context)
require("99").Providers.OpenCodeProvider._get_default_model()
require("99").Providers.OpenCodeProvider._get_provider_name()
require("99").Providers.OpenCodeProvider.fetch_models(callback)
require("99").WARN -- number
require("99").__debug()
require("99").__get_state()
require("99").add_md_file(md)
require("99").clear_all_marks()
require("99").clear_previous_requests()
require("99").get_model()
require("99").get_provider()
require("99").info()
require("99").next_request_logs()
require("99").open()
require("99").open_qfix_for_request(request)
require("99").open_tutorial(context)
require("99").prev_request_logs()
require("99").rm_md_file(md)
require("99").search(opts)
require("99").set_model(model)
require("99").set_provider(provider)
require("99").setup(opts)
require("99").stop_all_requests()
require("99").tutorial(opts)
require("99").vibe(opts)
require("99").view_logs()
require("99").visual(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help 99`, the local README, and the GitHub README listed below.

- `require("99").Providers.BaseProvider.make_request(self, query, context, observer)`
- `require("99").Providers.ClaudeCodeProvider._build_command(_, query, context)`
- `require("99").Providers.CursorAgentProvider._build_command(_, query, context)`
- `require("99").Providers.GeminiCLIProvider._build_command(_, query, context)`
- `require("99").Providers.KiroProvider._build_command(_, query, context)`
- `require("99").Providers.OpenCodeProvider._build_command(_, query, context)`
- `require("99").Providers.BaseProvider._retrieve_response(self, context)`
- `require("99").Extensions.Worker.craft_prompt(worker)`

## References

- Help: `:help 99` and `:help 99.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/99/README.md`
- GitHub README: https://github.com/ThePrimeagen/99/blob/master/README.md

_Generated in headless mode with forced plugin load._
