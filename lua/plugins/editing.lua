return {
  -- Code commenting
  {
    "numToStr/Comment.nvim",
    opts = {},
    lazy = false,
  },

  -- Surround text objects with (), "", etc.
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup({})
    end,
  },

  -- Auto-save functionality
  {
    "Pocco81/auto-save.nvim",
    config = function()
      require("auto-save").setup({
        enabled = true,
        execution_message = {
          message = function()
            return "💾 Auto-saved at " .. vim.fn.strftime("%H:%M:%S")
          end,
          dim = 0.5,
          cleaning_interval = 1250,
        },
        trigger_events = { "TextChanged", "InsertLeave" },
        debounce_delay = 1500,
      })
    end,
  },
}
