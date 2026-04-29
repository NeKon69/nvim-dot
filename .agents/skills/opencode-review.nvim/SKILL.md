# Opencode-review.nvim API Reference

Local plugin at `local/opencode-review.nvim`.

## Purpose

- Handles OpenCode edit permission events with a custom scratch diff review UI.
- Logs debug information to `stdpath("log") .. "/opencode-review.log"` when `debug = true`.
- Subscribes directly to OpenCode's local SSE endpoint with `curl -N /event`.
- Opens one reviewed file at a time as a full-file scratch buffer using the target filetype, with changed lines highlighted.
- Accepting every file permits the whole OpenCode edit request with `once`.
- Rejecting any file rejects the whole OpenCode edit request.
- Sends normal/visual review notes into the OpenCode prompt without submitting.

## Commands

- `:OpencodeReviewAcceptFile`
- `:OpencodeReviewReject`
- `:OpencodeReviewComment`
- `:OpencodeReviewStart`
- `:OpencodeReviewStop`

## Default Buffer Keymaps

- `da`: accept current preview file, or permit the request after the final file
- `da`: locally approve the current file and jump to the next unapproved edited file (stays in the same tab). On the last file, accepts the whole change.
- `dA`: approve the whole OpenCode edit request
- `dr`: reject the whole request
- `dq`: close preview and reject the whole request
- `dc`: reject the pending edit, keep the preview open, open the OpenCode window, insert a newline, and paste current line or visual selection as a bracketed-paste review note with `+`/`-`/space diff prefixes
- `]c`: jump to next changed hunk in the review buffer
- `[c`: jump to previous changed hunk in the review buffer

## Behavior

- The preview starts at the first changed hunk.
- Local file approvals are tracked in Neovim only; the first `dc` after any local approvals prepends the approved file list to the review note.
- Approved files are tracked across separate one-file permission requests until the first `dc` consumes that note.
- The approved-file note is scoped to the current OpenCode response and cleared when the session goes idle with no active/queued reviews.
- Concurrent one-file edit permission requests are queued and shown one at a time after `da`/`dr` handles the active preview.

## Module API

```lua
require("opencode-review").setup(opts)
require("opencode-review").accept_file()
require("opencode-review").reject_request()
```

## Notes

- Uses direct HTTP replies to `POST /permission/{requestID}/reply`; review comments are sent via terminal bracketed paste with `POST /tui/append-prompt` as a fallback.
- `opencode.nvim` native edit previews should be disabled when this plugin is active.
- The OpenCode terminal should run on the configured fixed port, currently `27100`.
