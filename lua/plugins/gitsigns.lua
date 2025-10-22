return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signcolumn = true,  
    numhl = true,       
    linehl = false,     
    word_diff = false,  
    
    current_line_blame = false, 
    current_line_blame_opts = {
      virt_text_pos = 'eol', 
      delay = 1000,
    },
  },
}
