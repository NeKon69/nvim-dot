# User.keymaps API Reference

Source: `lua/user/keymaps.lua`

## File Behavior

- Central keymap registry for search, project, splits, diagnostics, git, build, and history navigation.
- Uses leader prefix groups as namespaces (`<leader>f`, `<leader>p`, `<leader>x`, `<leader>b`, etc.).
- `open_in_split(split_type)`: opens Telescope `find_files` and remaps `<CR>` to horizontal/vertical selection action.
- Integrates `user.history`, `user.templates`, Telescope, Harpoon, NvimTree, Trouble, and Overseer-related commands.

## Module API (`user.keymaps`)

- Exported module functions: none (keymaps are installed at file load time).

## Keymaps

- `<leader>ff`: Telescope find files.
- `<leader>fs`: Telescope recent files limited to cwd.
- `<leader>fg`: Telescope live grep.
- `<leader>fb`: Telescope buffers.
- `<leader>fo`: Telescope global recent files.
- `<leader>e`: toggle floating NvimTree and focus current file.
- `<leader>pn`: create file from user template.
- `<leader>ps`: open cwd picker via `:CwdPick`.
- `<leader>ha`: add current file to Harpoon list.
- `<leader>hh`: open/toggle Harpoon quick menu.
- `<leader>sv`: open file picker and open selected file in vertical split.
- `<leader>sh`: open file picker and open selected file in horizontal split.
- `<leader>se`: equalize split sizes.
- `<leader>sx`: close current split.
- `<leader>gg`: open LazyGit.
- `<leader>ca`: run LSP code action.
- `<leader>xx`: toggle Trouble view.
- `<leader>xw`: open workspace diagnostics in Trouble.
- `<leader>xd`: open document diagnostics in Trouble.
- `gl`: open diagnostics float on current line.
- `[d`: jump to previous diagnostic.
- `]d`: jump to next diagnostic.
- `<leader>bb`: open Overseer tasks picker.
- `<leader>br`: rerun last Overseer task.
- `<leader>bs`: stop active Overseer task.
- `<leader>bo`: toggle Overseer panel.
- `<leader>ph`: list project history.
- `<M-q>`: navigate history backward.
- `<M-w>`: navigate history forward.
- `<C-h>`: window-left navigation.
- `<C-j>`: window-down navigation.
- `<C-k>`: window-up navigation.
- `<C-l>`: window-right navigation.

## Commands, Events

- User commands: none defined in this file.
- Autocmd events: none defined in this file.
