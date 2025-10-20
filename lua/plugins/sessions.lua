return {
  "rmagatti/auto-session",
  config = function()
    local autosession = require("auto-session")

    autosession.setup({
      auto_session_enable_last_session = false,  
      auto_save_enabled = true,        
      auto_restore_enabled = false,             
      log_level = "error",
      pre_save_cmds = { "NvimTreeClose" },      
      post_restore_cmds = {},                   
    })

    vim.api.nvim_create_user_command("AutoSessionSave", function()
      autosession.SaveSession()
    end, { desc = "Save current session" })

    vim.api.nvim_create_user_command("AutoSessionRestore", function()
      autosession.RestoreSession()
    end, { desc = "Restore last saved session" })

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

