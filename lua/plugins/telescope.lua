return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find Files" })
    require("telescope").setup{
              defaults = {
    layout_strategy = "vertical",   -- указывается отдельно
    sorting_strategy = "ascending",
    layout_config = {
      vertical = {                  -- только конфигурация для vertical
        prompt_position = "top",
        preview_position = "bottom",
        width = 0.54,
        height = 0.38,
        mirror = true,
        preview_cutoff = 0,
      },
    },
    border = true,
    borderchars = { "─", "│", "─", "│", "┌", "┐", "┘", "└" },
    borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },

    color_devicons = true,
    path_display = { "truncate" },
    prompt_title = "Search",
    results_title = "Files",
    preview_title = "Preview",
  },
    }
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#5daeff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#b464ff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#cf55ff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#fa6fff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "#ff5555", bg = "NONE" })
        vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ffea00", bg = "NONE" })

  end,
}

