# Nvim-ufo API Reference

This file is generated for plugin `kevinhwang91/nvim-ufo` and module `ufo`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`ufo`)

```lua
require("ufo") -- table
require("ufo").applyFolds(bufnr, ranges)
require("ufo").attach(bufnr)
require("ufo").closeAllFolds()
require("ufo").closeFoldsWith(level)
require("ufo").detach(bufnr)
require("ufo").disable()
require("ufo").disableFold(bufnr)
require("ufo").enable()
require("ufo").enableFold(bufnr)
require("ufo").getFolds(bufnr, providerName)
require("ufo").goNextClosedFold()
require("ufo").goPreviousClosedFold()
require("ufo").goPreviousStartFold()
require("ufo").hasAttached(bufnr)
require("ufo").inspect(bufnr)
require("ufo").openAllFolds()
require("ufo").openFoldsExceptKinds(kinds)
require("ufo").peekFoldedLinesUnderCursor(enter, nextLineIncluded)
require("ufo").setFoldVirtTextHandler(bufnr, handler)
require("ufo").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help ufo`, the local README, and the GitHub README listed below.

- `require("ufo").applyFolds(bufnr, ranges)`
- `require("ufo").getFolds(bufnr, providerName)`
- `require("ufo").peekFoldedLinesUnderCursor(enter, nextLineIncluded)`
- `require("ufo").setFoldVirtTextHandler(bufnr, handler)`
- `require("ufo").attach(bufnr)`
- `require("ufo").closeFoldsWith(level)`
- `require("ufo").detach(bufnr)`
- `require("ufo").disableFold(bufnr)`

## References

- Help: `:help ufo` and `:help ufo.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-ufo/README.md`
- GitHub README: https://github.com/kevinhwang91/nvim-ufo/blob/master/README.md

_Generated in headless mode with forced plugin load._
