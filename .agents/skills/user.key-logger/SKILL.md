# User.key-logger API Reference

Source: `lua/user/key-logger.lua`

## File Behavior

- `log_path`: writes diagnostics to `stdpath("cache")/triforce_spy.log`.
- Startup block: truncates/creates the log file and writes a session header.
- `log_to_file(event_type, match)`: appends timestamped event records.
- Runtime side effects: prints manual tracing instructions when the file is loaded.

## Module API (`user.key-logger`)

- Exported module functions: none (this file is side-effect driven and does not return `M`).

## Commands, Keymaps, Events

- User commands: none defined.
- Keymaps: none defined.
- `User`: logged with event name + match.
- `FileType`: logged with event name + filetype match.
- `TermOpen`: logged for terminal open activity.
- `BufEnter`: logged for buffer-entry activity.
