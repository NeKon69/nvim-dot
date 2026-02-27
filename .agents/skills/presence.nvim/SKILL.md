# Presence.nvim API Reference

This file is generated for plugin `andweeb/presence.nvim` and module `presence`.
Use it as a fast API/command index before reading source.

## Commands (`:`) added after force-load

_No new user commands detected from runtime diff._

## Module API (`presence`)

```lua
require("presence") -- table
require("presence").authorize(p1, p2)
require("presence").auto_update -- number
require("presence").blacklist -- table
require("presence").buttons -- number
require("presence").call_remote_method(p1, p2, p3, p4)
require("presence").call_remote_nvim_instance(p1, p2, p3)
require("presence").cancel(p1)
require("presence").check_blacklist(p1, p2, p3, p4)
require("presence").check_discord_socket(p1, p2)
require("presence").check_dup_options(p1, p2)
require("presence").client_id -- string
require("presence").coalesce_option(p1)
require("presence").connect(p1, p2)
require("presence").debounce_timeout -- number
require("presence").discord -- table
require("presence").discord.authorize(p1, p2)
require("presence").discord.call(p1, p2, p3, p4)
require("presence").discord.client_id -- string
require("presence").discord.connect(p1, p2)
require("presence").discord.decode_json(p1, p2)
require("presence").discord.disconnect(p1, p2)
require("presence").discord.encode_json(p1, p2)
require("presence").discord.events -- table
require("presence").discord.events.ERROR -- string
require("presence").discord.events.READY -- string
require("presence").discord.generate_uuid(p1)
require("presence").discord.init(p1, p2)
require("presence").discord.ipc_socket -- string
require("presence").discord.is_connected(p1)
require("presence").discord.log -- table
require("presence").discord.log.codes -- table
require("presence").discord.log.codes.debug -- number
require("presence").discord.log.codes.error -- number
require("presence").discord.log.codes.info -- number
require("presence").discord.log.codes.warn -- number
require("presence").discord.log.debug(p1, p2)
require("presence").discord.log.error(p1, p2)
require("presence").discord.log.info(p1, p2)
require("presence").discord.log.init(p1, p2)
require("presence").discord.log.levels -- table
require("presence").discord.log.levels.1 -- table
require("presence").discord.log.levels.2 -- table
require("presence").discord.log.levels.3 -- table
require("presence").discord.log.levels.4 -- table
require("presence").discord.log.warn(p1, p2)
require("presence").discord.opcodes -- table
require("presence").discord.opcodes.auth -- number
require("presence").discord.opcodes.closed -- number
require("presence").discord.opcodes.frame -- number
require("presence").discord.pipe -- userdata
require("presence").discord.read_message(p1, p2, p3, p4, p5)
require("presence").discord.set_activity(p1, p2, p3)
require("presence").discord_event(p1)
require("presence").editing_text -- string
require("presence").enable_line_number -- number
require("presence").file_assets -- table
require("presence").file_assets..aliases -- table
require("presence").file_assets..aliases.1 -- string
require("presence").file_assets..aliases.2 -- string
require("presence").file_assets..appveyor.yml -- table
require("presence").file_assets..appveyor.yml.1 -- string
require("presence").file_assets..appveyor.yml.2 -- string
require("presence").file_assets..babelrc -- table
require("presence").file_assets..babelrc.1 -- string
require("presence").file_assets..babelrc.2 -- string
require("presence").file_assets..babelrc.cjs -- table
require("presence").file_assets..babelrc.cjs.1 -- string
require("presence").file_assets..babelrc.cjs.2 -- string
require("presence").file_assets..babelrc.js -- table
require("presence").file_assets..babelrc.js.1 -- string
require("presence").file_assets..babelrc.js.2 -- string
require("presence").file_assets..babelrc.json -- table
require("presence").file_assets..babelrc.json.1 -- string
require("presence").file_assets..babelrc.json.2 -- string
require("presence").file_assets..babelrc.mjs -- table
require("presence").file_assets..babelrc.mjs.1 -- string
require("presence").file_assets..babelrc.mjs.2 -- string
require("presence").file_assets..bash_login -- table
require("presence").file_assets..bash_login.1 -- string
require("presence").file_assets..bash_login.2 -- string
require("presence").file_assets..bash_logout -- table
require("presence").file_assets..bash_logout.1 -- string
require("presence").file_assets..bash_logout.2 -- string
require("presence").file_assets..bash_profile -- table
require("presence").file_assets..bash_profile.1 -- string
require("presence").file_assets..bash_profile.2 -- string
require("presence").file_assets..bash_prompt -- table
require("presence").file_assets..bash_prompt.1 -- string
require("presence").file_assets..bash_prompt.2 -- string
require("presence").file_assets..bashrc -- table
require("presence").file_assets..bashrc.1 -- string
require("presence").file_assets..bashrc.2 -- string
require("presence").file_assets..cshrc -- table
require("presence").file_assets..cshrc.1 -- string
require("presence").file_assets..cshrc.2 -- string
require("presence").file_assets..dockercfg -- table
require("presence").file_assets..dockercfg.1 -- string
require("presence").file_assets..dockercfg.2 -- string
require("presence").file_assets..dockerfile -- table
require("presence").file_assets..dockerfile.1 -- string
require("presence").file_assets..dockerfile.2 -- string
require("presence").file_assets..dockerignore -- table
require("presence").file_assets..dockerignore.1 -- string
require("presence").file_assets..dockerignore.2 -- string
require("presence").file_assets..editorconfig -- table
require("presence").file_assets..editorconfig.1 -- string
require("presence").file_assets..editorconfig.2 -- string
require("presence").file_assets..eslintignore -- table
require("presence").file_assets..eslintignore.1 -- string
require("presence").file_assets..eslintignore.2 -- string
require("presence").file_assets..eslintrc -- table
require("presence").file_assets..eslintrc.1 -- string
require("presence").file_assets..eslintrc.2 -- string
require("presence").file_assets..eslintrc.cjs -- table
require("presence").file_assets..eslintrc.cjs.1 -- string
require("presence").file_assets..eslintrc.cjs.2 -- string
require("presence").file_assets..eslintrc.js -- table
require("presence").file_assets..eslintrc.js.1 -- string
require("presence").file_assets..eslintrc.js.2 -- string
require("presence").file_assets..eslintrc.json -- table
require("presence").file_assets..eslintrc.json.1 -- string
require("presence").file_assets..eslintrc.json.2 -- string
require("presence").file_assets..eslintrc.yaml -- table
require("presence").file_assets..eslintrc.yaml.1 -- string
require("presence").file_assets..eslintrc.yaml.2 -- string
require("presence").file_assets..eslintrc.yml -- table
require("presence").file_assets..eslintrc.yml.1 -- string
require("presence").file_assets..eslintrc.yml.2 -- string
require("presence").file_assets..gitattributes -- table
require("presence").file_assets..gitattributes.1 -- string
require("presence").file_assets..gitattributes.2 -- string
require("presence").file_assets..gitconfig -- table
require("presence").file_assets..gitconfig.1 -- string
require("presence").file_assets..gitconfig.2 -- string
require("presence").file_assets..gitignore -- table
require("presence").file_assets..gitignore.1 -- string
require("presence").file_assets..gitignore.2 -- string
require("presence").file_assets..gitlab-ci.yaml -- table
require("presence").file_assets..gitlab-ci.yaml.1 -- string
require("presence").file_assets..gitlab-ci.yaml.2 -- string
require("presence").file_assets..gitlab-ci.yml -- table
require("presence").file_assets..gitlab-ci.yml.1 -- string
require("presence").file_assets..gitlab-ci.yml.2 -- string
require("presence").file_assets..gitmodules -- table
require("presence").file_assets..gitmodules.1 -- string
require("presence").file_assets..gitmodules.2 -- string
require("presence").file_assets..login -- table
require("presence").file_assets..login.1 -- string
require("presence").file_assets..login.2 -- string
require("presence").file_assets..logout -- table
require("presence").file_assets..logout.1 -- string
require("presence").file_assets..logout.2 -- string
require("presence").file_assets..luacheckrc -- table
require("presence").file_assets..luacheckrc.1 -- string
require("presence").file_assets..luacheckrc.2 -- string
require("presence").file_assets..npmignore -- table
require("presence").file_assets..npmignore.1 -- string
require("presence").file_assets..npmignore.2 -- string
require("presence").file_assets..npmrc -- table
require("presence").file_assets..npmrc.1 -- string
require("presence").file_assets..npmrc.2 -- string
require("presence").file_assets..nvmrc -- table
require("presence").file_assets..nvmrc.1 -- string
require("presence").file_assets..nvmrc.2 -- string
require("presence").file_assets..prettierrc -- table
require("presence").file_assets..prettierrc.1 -- string
require("presence").file_assets..prettierrc.2 -- string
require("presence").file_assets..prettierrc.cjs -- table
require("presence").file_assets..prettierrc.cjs.1 -- string
require("presence").file_assets..prettierrc.cjs.2 -- string
require("presence").file_assets..prettierrc.js -- table
require("presence").file_assets..prettierrc.js.1 -- string
require("presence").file_assets..prettierrc.js.2 -- string
require("presence").file_assets..prettierrc.json -- table
require("presence").file_assets..prettierrc.json.1 -- string
require("presence").file_assets..prettierrc.json.2 -- string
require("presence").file_assets..prettierrc.json5 -- table
require("presence").file_assets..prettierrc.json5.1 -- string
require("presence").file_assets..prettierrc.json5.2 -- string
require("presence").file_assets..prettierrc.toml -- table
require("presence").file_assets..prettierrc.toml.1 -- string
require("presence").file_assets..prettierrc.toml.2 -- string
require("presence").file_assets..prettierrc.yaml -- table
require("presence").file_assets..prettierrc.yaml.1 -- string
require("presence").file_assets..prettierrc.yaml.2 -- string
require("presence").file_assets..prettierrc.yml -- table
require("presence").file_assets..prettierrc.yml.1 -- string
require("presence").file_assets..prettierrc.yml.2 -- string
require("presence").file_assets..profile -- table
require("presence").file_assets..profile.1 -- string
require("presence").file_assets..profile.2 -- string
require("presence").file_assets..tcshrc -- table
require("presence").file_assets..tcshrc.1 -- string
require("presence").file_assets..tcshrc.2 -- string
require("presence").file_assets..terraformrc -- table
require("presence").file_assets..terraformrc.1 -- string
require("presence").file_assets..terraformrc.2 -- string
require("presence").file_assets..tmux.conf -- table
require("presence").file_assets..tmux.conf.1 -- string
```

## Harder Calls (quick notes)

- `require("presence").discord.read_message(p1, p2, p3, p4, p5)`: argument contract may be non-obvious; check :help/README.
- `require("presence").call_remote_method(p1, p2, p3, p4)`: argument contract may be non-obvious; check :help/README.
- `require("presence").check_blacklist(p1, p2, p3, p4)`: argument contract may be non-obvious; check :help/README.
- `require("presence").discord.call(p1, p2, p3, p4)`: argument contract may be non-obvious; check :help/README.
- `require("presence").call_remote_nvim_instance(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("presence").discord.set_activity(p1, p2, p3)`: argument contract may be non-obvious; check :help/README.
- `require("presence").authorize(p1, p2)`: argument contract may be non-obvious; check :help/README.
- `require("presence").check_discord_socket(p1, p2)`: argument contract may be non-obvious; check :help/README.

## References

- Help: `:help presence` and `:help presence.*` topics
- Local README: `/home/progamers/.local/share/nvim/lazy/presence.nvim/README.md`
- GitHub README: https://github.com/andweeb/presence.nvim/blob/master/README.md

_Generated in headless mode with forced plugin load._
