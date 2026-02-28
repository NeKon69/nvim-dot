# User.targets_config API Reference

This file is generated for source `lua/user/targets_config.lua`.
Use it as a fast API/command index before reading source.

## Commands (`:`) detected in file

_No user commands detected in static scan._

## Module API (`user.targets_config`)

```lua
require("user.targets_config").config_file_path()

require("user.targets_config").delete_profile(target_name, profile_name)

require("user.targets_config").delete_target(target_name)

require("user.targets_config").ensure_files()

require("user.targets_config").get_active()

require("user.targets_config").get_effective(action_name)

require("user.targets_config").list_profiles(target_name)

require("user.targets_config").list_targets()

require("user.targets_config").load_config()

require("user.targets_config").refresh_from_just(available_targets, available_profiles)

require("user.targets_config").render_template(value, effective)

require("user.targets_config").resolve_active()

require("user.targets_config").resolve_args(effective)

require("user.targets_config").resolve_cwd(effective)

require("user.targets_config").resolve_program(effective, probe_runner)

require("user.targets_config").resolve_relative_path(path)

require("user.targets_config").set_active_profile(profile_name)

require("user.targets_config").set_active_target(target_name)

require("user.targets_config").upsert_target_profile(target_name, profile_name, payload)

require("user.targets_config").write_config(cfg)

```

## Harder Calls (quick notes)

These calls are likely harder to wire correctly because they often have broader argument contracts, stateful behavior, or side effects.
Before wiring them into keymaps/autocmds, verify expected input/output behavior in local code and related docs/skills.

- `upsert_target_profile(target_name, profile_name, payload)`

- `delete_profile(target_name, profile_name)`

- `refresh_from_just(available_targets, available_profiles)`

- `render_template(value, effective)`

- `resolve_program(effective, probe_runner)`

- `delete_target(target_name)`

- `get_effective(action_name)`

- `list_profiles(target_name)`


## References

_No plugin/module references detected._

_Generated in headless mode from static file analysis._
