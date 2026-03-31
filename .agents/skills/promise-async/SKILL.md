# Promise-async API Reference

This file is generated for plugin `kevinhwang91/promise-async` and module `async`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`async`)

```lua
require("async") -- table
require("async")._id -- table
require("async")._id.1 -- string
require("async").sync(executor)
require("async").wait(p)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help async`, the local README, and the GitHub README listed below.

- `require("async").sync(executor)`
- `require("async").wait(p)`

## References

- Help: `:help async` and `:help async.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/promise-async/README.md`
- GitHub README: https://github.com/kevinhwang91/promise-async/blob/master/README.md

_Generated in headless mode with forced plugin load._
