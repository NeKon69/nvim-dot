# External.minuet_ai_nvim API Reference

This file is generated for plugin `milanglacier/minuet-ai.nvim` and module `minuet`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`minuet`)

```lua
require("minuet") -- table
require("minuet").change_model(provider_model)
require("minuet").change_preset(preset)
require("minuet").change_provider(provider)
require("minuet").make_blink_map()
require("minuet").make_cmp_map()
require("minuet").setup(config)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help minuet`, the local README, and the GitHub README listed below.

- `require("minuet").change_model(provider_model)`
- `require("minuet").change_preset(preset)`
- `require("minuet").change_provider(provider)`
- `require("minuet").setup(config)`
- `require("minuet").make_blink_map()`
- `require("minuet").make_cmp_map()`

## References

- Help: `:help minuet` and `:help minuet.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/minuet-ai.nvim/README.md`
- GitHub README: https://github.com/milanglacier/minuet-ai.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
