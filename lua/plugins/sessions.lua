return {
  "rmagatti/auto-session",
  config = function()
    require("auto-session").setup({
      log_level = "error",
      auto_session_enable_last_session = true,
      auto_session_root_dir = vim.fn.stdpath("data") .. "/sessions/",
      auto_session_enabled = true,
      auto_save_enabled = true,
      auto_restore_enabled = true,
      auto_session_suppress_dirs = {"~/", "~/Downloads", "/"},
      auto_session_use_git_branch = false,
      
      session_lens = {
        load_on_setup = true,
        theme_conf = {border = true},
        previewer = false,
      },
    })
    
    vim.keymap.set("n", "<leader>ss", "<Cmd>SessionSave<CR>", {desc = "Save session"})
    vim.keymap.set("n", "<leader>sr", "<Cmd>SessionRestore<CR>", {desc = "Restore session"})
    vim.keymap.set("n", "<leader>sd", "<Cmd>SessionDelete<CR>", {desc = "Delete session"})
    
    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        local argc = vim.fn.argc()
        local first = vim.fn.argv(0)
        if argc == 0 or (argc == 1 and vim.fn.isdirectory(first) == 1) then
          require("auto-session").RestoreSession()
        end
      end,
    })
  end,
}

