# Nvim-lint API Reference

This file is generated for plugin `mfussenegger/nvim-lint` and module `lint`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`lint`)

```lua
require("lint") -- table
require("lint")._resolve_linter_by_ft(p1)
require("lint").get_namespace(p1)
require("lint").get_running(p1)
require("lint").lint(p1, p2)
require("lint").linters -- table
require("lint").linters_by_ft -- table
require("lint").linters_by_ft.clojure -- table
require("lint").linters_by_ft.clojure.1 -- string
require("lint").linters_by_ft.dockerfile -- table
require("lint").linters_by_ft.dockerfile.1 -- string
require("lint").linters_by_ft.inko -- table
require("lint").linters_by_ft.inko.1 -- string
require("lint").linters_by_ft.janet -- table
require("lint").linters_by_ft.janet.1 -- string
require("lint").linters_by_ft.json -- table
require("lint").linters_by_ft.json.1 -- string
require("lint").linters_by_ft.markdown -- table
require("lint").linters_by_ft.markdown.1 -- string
require("lint").linters_by_ft.rst -- table
require("lint").linters_by_ft.rst.1 -- string
require("lint").linters_by_ft.ruby -- table
require("lint").linters_by_ft.ruby.1 -- string
require("lint").linters_by_ft.terraform -- table
require("lint").linters_by_ft.terraform.1 -- string
require("lint").linters_by_ft.text -- table
require("lint").linters_by_ft.text.1 -- string
require("lint").try_lint(p1, p2)
```

## Harder Calls (quick notes)

- `require("lint").lint(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("lint").try_lint(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("lint")._resolve_linter_by_ft(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lint").get_namespace(p1)`: argument contract may be non-obvious; check :help/README.
- `require("lint").get_running(p1)`: side-effecting call; validate inputs and error paths.

## References

- Help: `:help lint` and `:help lint.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-lint/README.md`
- GitHub README: https://github.com/mfussenegger/nvim-lint/blob/master/README.md

_Generated in headless mode with forced plugin load._
