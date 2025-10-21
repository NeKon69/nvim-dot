-- lua/plugins/gitsigns.lua
return {
  "lewis6991/gitsigns.nvim",
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    -- Configuration for the signs in the gutter
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signcolumn = true,  -- Always show the sign column
    numhl = true,       -- Highlight the line number
    linehl = false,     -- Don't highlight the whole line
    word_diff = false,  -- Don't highlight individual word diffs
    
    -- Other settings
    current_line_blame = false, -- Don't show blame info on the current line
    current_line_blame_opts = {
      virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
      delay = 1000,
    },
  },
}
