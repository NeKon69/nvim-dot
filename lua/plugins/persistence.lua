return {
  "folke/persistence.nvim",
  event = "VimEnter",
  opts = {
    dir = vim.fn.stdpath("state") .. "/sessions/",
    need = 0,
    branch = false,
  },
  keys = {
    {
      "<leader>qs",
      function() require("persistence").load() end,
      desc = "💾 Restore Session",
    },
    {
      "<leader>qS",
      function() require("persistence").select() end,
      desc = "📂 Select Session",
    },
    {
      "<leader>ql",
      function() require("persistence").load({ last = true }) end,
      desc = "⏮️  Restore Last Session",
    },
    {
      "<leader>qd",
      function() require("persistence").stop() end,
      desc = "🚫 Don't Save Current Session",
    },
  },
  init = function()
    vim.api.nvim_create_autocmd("VimEnter", {
      group = vim.api.nvim_create_augroup("persistence_autoload", { clear = true }),
      callback = function()
        require("persistence").load()
      end,
      nested = true,
    })
  end,
}

