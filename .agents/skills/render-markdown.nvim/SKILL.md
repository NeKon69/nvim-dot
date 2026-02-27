# Render-markdown.nvim API Reference

This file is generated for plugin `MeanderingProgrammer/render-markdown.nvim` and module `render-markdown`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

```vim
:RenderMarkdown
```

## Module API (`render-markdown`)

```lua
require("render-markdown") -- table
require("render-markdown").default -- table
require("render-markdown").default.anti_conceal -- table
require("render-markdown").default.anti_conceal.above -- number
require("render-markdown").default.anti_conceal.below -- number
require("render-markdown").default.anti_conceal.disabled_modes -- boolean
require("render-markdown").default.anti_conceal.enabled -- boolean
require("render-markdown").default.anti_conceal.ignore -- table
require("render-markdown").default.anti_conceal.ignore.code_background -- boolean
require("render-markdown").default.anti_conceal.ignore.indent -- boolean
require("render-markdown").default.anti_conceal.ignore.sign -- boolean
require("render-markdown").default.anti_conceal.ignore.virtual_lines -- boolean
require("render-markdown").default.bullet -- table
require("render-markdown").default.bullet.enabled -- boolean
require("render-markdown").default.bullet.highlight -- string
require("render-markdown").default.bullet.icons -- table
require("render-markdown").default.bullet.icons.1 -- string
require("render-markdown").default.bullet.icons.2 -- string
require("render-markdown").default.bullet.icons.3 -- string
require("render-markdown").default.bullet.icons.4 -- string
require("render-markdown").default.bullet.left_pad -- number
require("render-markdown").default.bullet.ordered_icons(p1)
require("render-markdown").default.bullet.render_modes -- boolean
require("render-markdown").default.bullet.right_pad -- number
require("render-markdown").default.bullet.scope_highlight -- table
require("render-markdown").default.callout -- table
require("render-markdown").default.callout.abstract -- table
require("render-markdown").default.callout.abstract.category -- string
require("render-markdown").default.callout.abstract.highlight -- string
require("render-markdown").default.callout.abstract.raw -- string
require("render-markdown").default.callout.abstract.rendered -- string
require("render-markdown").default.callout.attention -- table
require("render-markdown").default.callout.attention.category -- string
require("render-markdown").default.callout.attention.highlight -- string
require("render-markdown").default.callout.attention.raw -- string
require("render-markdown").default.callout.attention.rendered -- string
require("render-markdown").default.callout.bug -- table
require("render-markdown").default.callout.bug.category -- string
require("render-markdown").default.callout.bug.highlight -- string
require("render-markdown").default.callout.bug.raw -- string
require("render-markdown").default.callout.bug.rendered -- string
require("render-markdown").default.callout.caution -- table
require("render-markdown").default.callout.caution.category -- string
require("render-markdown").default.callout.caution.highlight -- string
require("render-markdown").default.callout.caution.raw -- string
require("render-markdown").default.callout.caution.rendered -- string
require("render-markdown").default.callout.check -- table
require("render-markdown").default.callout.check.category -- string
require("render-markdown").default.callout.check.highlight -- string
require("render-markdown").default.callout.check.raw -- string
require("render-markdown").default.callout.check.rendered -- string
require("render-markdown").default.callout.cite -- table
require("render-markdown").default.callout.cite.category -- string
require("render-markdown").default.callout.cite.highlight -- string
require("render-markdown").default.callout.cite.raw -- string
require("render-markdown").default.callout.cite.rendered -- string
require("render-markdown").default.callout.danger -- table
require("render-markdown").default.callout.danger.category -- string
require("render-markdown").default.callout.danger.highlight -- string
require("render-markdown").default.callout.danger.raw -- string
require("render-markdown").default.callout.danger.rendered -- string
require("render-markdown").default.callout.done -- table
require("render-markdown").default.callout.done.category -- string
require("render-markdown").default.callout.done.highlight -- string
require("render-markdown").default.callout.done.raw -- string
require("render-markdown").default.callout.done.rendered -- string
require("render-markdown").default.callout.error -- table
require("render-markdown").default.callout.error.category -- string
require("render-markdown").default.callout.error.highlight -- string
require("render-markdown").default.callout.error.raw -- string
require("render-markdown").default.callout.error.rendered -- string
require("render-markdown").default.callout.example -- table
require("render-markdown").default.callout.example.category -- string
require("render-markdown").default.callout.example.highlight -- string
require("render-markdown").default.callout.example.raw -- string
require("render-markdown").default.callout.example.rendered -- string
require("render-markdown").default.callout.fail -- table
require("render-markdown").default.callout.fail.category -- string
require("render-markdown").default.callout.fail.highlight -- string
require("render-markdown").default.callout.fail.raw -- string
require("render-markdown").default.callout.fail.rendered -- string
require("render-markdown").default.callout.failure -- table
require("render-markdown").default.callout.failure.category -- string
require("render-markdown").default.callout.failure.highlight -- string
require("render-markdown").default.callout.failure.raw -- string
require("render-markdown").default.callout.failure.rendered -- string
require("render-markdown").default.callout.faq -- table
require("render-markdown").default.callout.faq.category -- string
require("render-markdown").default.callout.faq.highlight -- string
require("render-markdown").default.callout.faq.raw -- string
require("render-markdown").default.callout.faq.rendered -- string
require("render-markdown").default.callout.help -- table
require("render-markdown").default.callout.help.category -- string
require("render-markdown").default.callout.help.highlight -- string
require("render-markdown").default.callout.help.raw -- string
require("render-markdown").default.callout.help.rendered -- string
require("render-markdown").default.callout.hint -- table
require("render-markdown").default.callout.hint.category -- string
require("render-markdown").default.callout.hint.highlight -- string
require("render-markdown").default.callout.hint.raw -- string
require("render-markdown").default.callout.hint.rendered -- string
require("render-markdown").default.callout.important -- table
require("render-markdown").default.callout.important.category -- string
require("render-markdown").default.callout.important.highlight -- string
require("render-markdown").default.callout.important.raw -- string
require("render-markdown").default.callout.important.rendered -- string
require("render-markdown").default.callout.info -- table
require("render-markdown").default.callout.info.category -- string
require("render-markdown").default.callout.info.highlight -- string
require("render-markdown").default.callout.info.raw -- string
require("render-markdown").default.callout.info.rendered -- string
require("render-markdown").default.callout.missing -- table
require("render-markdown").default.callout.missing.category -- string
require("render-markdown").default.callout.missing.highlight -- string
require("render-markdown").default.callout.missing.raw -- string
require("render-markdown").default.callout.missing.rendered -- string
require("render-markdown").default.callout.note -- table
require("render-markdown").default.callout.note.category -- string
require("render-markdown").default.callout.note.highlight -- string
require("render-markdown").default.callout.note.raw -- string
require("render-markdown").default.callout.note.rendered -- string
require("render-markdown").default.callout.question -- table
require("render-markdown").default.callout.question.category -- string
require("render-markdown").default.callout.question.highlight -- string
require("render-markdown").default.callout.question.raw -- string
require("render-markdown").default.callout.question.rendered -- string
require("render-markdown").default.callout.quote -- table
require("render-markdown").default.callout.quote.category -- string
require("render-markdown").default.callout.quote.highlight -- string
require("render-markdown").default.callout.quote.raw -- string
require("render-markdown").default.callout.quote.rendered -- string
require("render-markdown").default.callout.success -- table
require("render-markdown").default.callout.success.category -- string
require("render-markdown").default.callout.success.highlight -- string
require("render-markdown").default.callout.success.raw -- string
require("render-markdown").default.callout.success.rendered -- string
require("render-markdown").default.callout.summary -- table
require("render-markdown").default.callout.summary.category -- string
require("render-markdown").default.callout.summary.highlight -- string
require("render-markdown").default.callout.summary.raw -- string
require("render-markdown").default.callout.summary.rendered -- string
require("render-markdown").default.callout.tip -- table
require("render-markdown").default.callout.tip.category -- string
require("render-markdown").default.callout.tip.highlight -- string
require("render-markdown").default.callout.tip.raw -- string
require("render-markdown").default.callout.tip.rendered -- string
require("render-markdown").default.callout.tldr -- table
require("render-markdown").default.callout.tldr.category -- string
require("render-markdown").default.callout.tldr.highlight -- string
require("render-markdown").default.callout.tldr.raw -- string
require("render-markdown").default.callout.tldr.rendered -- string
require("render-markdown").default.callout.todo -- table
require("render-markdown").default.callout.todo.category -- string
require("render-markdown").default.callout.todo.highlight -- string
require("render-markdown").default.callout.todo.raw -- string
require("render-markdown").default.callout.todo.rendered -- string
require("render-markdown").default.callout.warning -- table
require("render-markdown").default.callout.warning.category -- string
require("render-markdown").default.callout.warning.highlight -- string
require("render-markdown").default.callout.warning.raw -- string
require("render-markdown").default.callout.warning.rendered -- string
require("render-markdown").default.change_events -- table
require("render-markdown").default.checkbox -- table
require("render-markdown").default.checkbox.bullet -- boolean
require("render-markdown").default.checkbox.checked -- table
require("render-markdown").default.checkbox.checked.highlight -- string
require("render-markdown").default.checkbox.checked.icon -- string
require("render-markdown").default.checkbox.custom -- table
require("render-markdown").default.checkbox.custom.todo -- table
require("render-markdown").default.checkbox.enabled -- boolean
require("render-markdown").default.checkbox.left_pad -- number
require("render-markdown").default.checkbox.render_modes -- boolean
require("render-markdown").default.checkbox.right_pad -- number
require("render-markdown").default.checkbox.unchecked -- table
require("render-markdown").default.checkbox.unchecked.highlight -- string
require("render-markdown").default.checkbox.unchecked.icon -- string
require("render-markdown").default.code -- table
require("render-markdown").default.code.above -- string
require("render-markdown").default.code.below -- string
require("render-markdown").default.code.border -- string
require("render-markdown").default.code.conceal_delimiters -- boolean
require("render-markdown").default.code.disable_background -- table
require("render-markdown").default.code.disable_background.1 -- string
require("render-markdown").default.code.enabled -- boolean
require("render-markdown").default.code.highlight -- string
require("render-markdown").default.code.highlight_border -- string
require("render-markdown").default.code.highlight_fallback -- string
require("render-markdown").default.code.highlight_info -- string
require("render-markdown").default.code.highlight_inline -- string
require("render-markdown").default.code.inline -- boolean
require("render-markdown").default.code.inline_left -- string
require("render-markdown").default.code.inline_pad -- number
require("render-markdown").default.code.inline_right -- string
require("render-markdown").default.code.language -- boolean
require("render-markdown").default.code.language_border -- string
require("render-markdown").default.code.language_icon -- boolean
require("render-markdown").default.code.language_info -- boolean
require("render-markdown").default.code.language_left -- string
require("render-markdown").default.code.language_name -- boolean
require("render-markdown").default.code.language_pad -- number
```

## Harder Calls (quick notes)

- `require("render-markdown").default.bullet.ordered_icons(p1)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help render-markdown` and `:help render-markdown.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/render-markdown.nvim/README.md`
- GitHub README: https://github.com/MeanderingProgrammer/render-markdown.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
