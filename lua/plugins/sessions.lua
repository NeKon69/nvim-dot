return {
  "rmagatti/auto-session",
  config = function()
    local autosession = require("auto-session")

    autosession.setup({
      autoload = true,
      auto_session_enable_last_session = true,  
      auto_save_enabled = true,        
      auto_restore_enabled = true,             
      log_level = "error",
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local argc = vim.fn.argc()
        local first = vim.fn.argv(0)
        if argc == 0 or (argc == 1 and vim.fn.isdirectory(first) == 1) then
          autosession.RestoreSession()
        end
      end,
    })
  end,
}

