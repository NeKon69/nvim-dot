return {
  "Exafunction/codeium.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "hrsh7th/nvim-cmp",
  },
  event = "InsertEnter",
  config = function()
    require("codeium").setup({
      enable_chat = false,
    })
    
    -- Add to lualine (optional)
    local function codeium_status()
      local status = vim.api.nvim_call_function("codeium#GetStatusString", {})
      if status == "" or status == " ON" then
        return ""
      end
      return status
    end
    
    -- Keybindings
    vim.keymap.set("i", "<Tab>", function()
      return vim.fn["codeium#Accept"]()
    end, {expr = true, silent = true})
    
    vim.keymap.set("i", "<C-]>", function()
      return vim.fn["codeium#Clear"]()
    end, {expr = true, silent = true})
    
    vim.keymap.set("i", "<C-n>", function()
      return vim.fn["codeium#CycleCompletions"](1)
    end, {expr = true, silent = true})
    
    vim.keymap.set("i", "<C-p>", function()
      return vim.fn["codeium#CycleCompletions"](-1)
    end, {expr = true, silent = true})
  end
}
