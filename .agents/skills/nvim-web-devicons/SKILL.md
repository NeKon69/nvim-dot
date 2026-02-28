# Nvim-web-devicons API Reference

This file is generated for plugin `nvim-tree/nvim-web-devicons` and module `nvim-web-devicons`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`nvim-web-devicons`)

```lua
require("nvim-web-devicons") -- table
require("nvim-web-devicons").get_default_icon()
require("nvim-web-devicons").get_icon(name, ext, opts)
require("nvim-web-devicons").get_icon_by_filetype(ft, opts)
require("nvim-web-devicons").get_icon_color(name, ext, opts)
require("nvim-web-devicons").get_icon_color_by_filetype(ft, opts)
require("nvim-web-devicons").get_icon_colors(name, ext, opts)
require("nvim-web-devicons").get_icon_colors_by_filetype(ft, opts)
require("nvim-web-devicons").get_icon_cterm_color(name, ext, opts)
require("nvim-web-devicons").get_icon_cterm_color_by_filetype(ft, opts)
require("nvim-web-devicons").get_icon_name_by_filetype(ft)
require("nvim-web-devicons").get_icons()
require("nvim-web-devicons").get_icons_by_desktop_environment()
require("nvim-web-devicons").get_icons_by_extension()
require("nvim-web-devicons").get_icons_by_filename()
require("nvim-web-devicons").get_icons_by_operating_system()
require("nvim-web-devicons").get_icons_by_window_manager()
require("nvim-web-devicons").has_loaded()
require("nvim-web-devicons").refresh()
require("nvim-web-devicons").set_default_icon(icon, color, cterm_color)
require("nvim-web-devicons").set_icon(user_icons_opts)
require("nvim-web-devicons").set_icon_by_filetype(user_filetypes)
require("nvim-web-devicons").set_up_highlights(allow_override)
require("nvim-web-devicons").setup(opts)
```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before using them in mappings/autocmds, confirm expected inputs and return/error behavior in `:help nvim-web-devicons`, the local README, and the GitHub README listed below.

- `require("nvim-web-devicons").get_icon(name, ext, opts)`
- `require("nvim-web-devicons").get_icon_color(name, ext, opts)`
- `require("nvim-web-devicons").get_icon_colors(name, ext, opts)`
- `require("nvim-web-devicons").get_icon_cterm_color(name, ext, opts)`
- `require("nvim-web-devicons").set_default_icon(icon, color, cterm_color)`
- `require("nvim-web-devicons").get_icon_by_filetype(ft, opts)`
- `require("nvim-web-devicons").get_icon_color_by_filetype(ft, opts)`
- `require("nvim-web-devicons").get_icon_colors_by_filetype(ft, opts)`

## References

- Help: `:help nvim-web-devicons` and `:help nvim-web-devicons.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/nvim-web-devicons/README.md`
- GitHub README: https://github.com/nvim-tree/nvim-web-devicons/blob/master/README.md

_Generated in headless mode with forced plugin load._
