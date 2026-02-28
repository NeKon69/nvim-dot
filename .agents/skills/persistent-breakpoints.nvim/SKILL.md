# Persistent-breakpoints.nvim API Reference

This file is generated for plugin `Weissle/persistent-breakpoints.nvim` and module `persistent-breakpoints`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:PBClearAllBreakpoints
:PBLoad
:PBReload
:PBSetConditionalBreakpoint
:PBSetLogPoint
:PBStore
:PBToggleBreakpoint
```

## Module API (`persistent-breakpoints`)

```lua
require("persistent-breakpoints") -- table
require("persistent-breakpoints").setup(_cfg)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help persistent-breakpoints`, the local README, and the GitHub README listed below.

- `require("persistent-breakpoints").setup(_cfg)`

## References

- Help: `:help persistent-breakpoints` and `:help persistent-breakpoints.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/persistent-breakpoints.nvim/README.md`
- GitHub README: https://github.com/Weissle/persistent-breakpoints.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
