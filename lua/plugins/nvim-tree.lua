return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    -- отключаем встроенный netrw
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    require("nvim-tree").setup({
      hijack_netrw = false,
      hijack_directories = { enable = false },
      hijack_unnamed_buffer_when_opening = false,
      open_on_tab = false,

      view = {
        float = {
          enable = true,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = math.floor(vim.o.columns * 0.5),
            height = math.floor(vim.o.lines * 0.6),
            row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
            col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.5)) / 2),
          },
        },
      },

      update_focused_file = {
        enable = true,
        update_root = true,
      },

      actions = {
        open_file = {
          quit_on_open = true,
          window_picker = { enable = true },
        },
      },

      renderer = {
        group_empty = true,
        icons = {
          glyphs = {
            git = {
              unstaged = "✗",
              staged = "✓",
              untracked = "★",
            },
          },
        },
      },

      sync_root_with_cwd = true,
      respect_buf_cwd = true,
    })

    vim.keymap.set("n", "<leader>e", function()
      require("nvim-tree.api").tree.toggle({ float = true })
    end, { desc = "Toggle file explorer (float)" })
  end,
}

