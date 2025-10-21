return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    "lewis6991/gitsigns.nvim",
  },
  event = "VeryLazy",
  
  opts = {
    options = {
      mode = "buffers",
      themable = true,
      numbers = "ordinal",
      
      close_command = "bdelete! %d",
      right_mouse_command = "bdelete! %d",
      left_mouse_command = "buffer %d",
      middle_mouse_command = nil,
      
      indicator = {
        icon = "▎",
        style = "icon",
      },
      
      buffer_close_icon = "×",
      modified_icon = "●",
      close_icon = "",
      left_trunc_marker = "",
      right_trunc_marker = "",
      
      max_name_length = 30,
      max_prefix_length = 15,
      truncate_names = true,
      tab_size = 21,
      
      diagnostics = "nvim_lsp",
      diagnostics_update_in_insert = false,
      diagnostics_indicator = function(count, level)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      
      offsets = {
        {
          filetype = "NvimTree",
          text = "File Explorer",
          text_align = "left",
          separator = true,
        }
      },
      
      color_icons = true,
      show_buffer_icons = true,
      show_buffer_close_icons = false,
      show_close_icon = false,
      show_tab_indicators = true,
      show_duplicate_prefix = true,
      persist_buffer_sort = true,
      
      separator_style = "slant",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      
      hover = {
        enabled = true,
        delay = 200,
        reveal = {"close"},
      },
      
      sort_by = "insert_after_current",
      
      -- Custom git status formatter
      custom_filter = function(buf_number, buf_numbers)
        local gitsigns_ok, gitsigns = pcall(require, "gitsigns")
        if gitsigns_ok then
          local status = vim.b[buf_number].gitsigns_status_dict
          if status then
            return status.added or status.changed or status.removed
          end
        end
        return true
      end,
    },
  },
  
  config = function(_, opts)
    require("bufferline").setup(opts)
    
    local map = vim.keymap.set
    
    map("n", "<A-,>", "<Cmd>BufferLineCyclePrev<CR>", {silent = true, desc = "Previous buffer"})
    map("n", "<A-.>", "<Cmd>BufferLineCycleNext<CR>", {silent = true, desc = "Next buffer"})
    map("n", "<A-<>", "<Cmd>BufferLineMovePrev<CR>", {silent = true, desc = "Move buffer left"})
    map("n", "<A->>", "<Cmd>BufferLineMoveNext<CR>", {silent = true, desc = "Move buffer right"})
    
    map("n", "<A-1>", "<Cmd>BufferLineGoToBuffer 1<CR>", {silent = true, desc = "Go to buffer 1"})
    map("n", "<A-2>", "<Cmd>BufferLineGoToBuffer 2<CR>", {silent = true, desc = "Go to buffer 2"})
    map("n", "<A-3>", "<Cmd>BufferLineGoToBuffer 3<CR>", {silent = true, desc = "Go to buffer 3"})
    map("n", "<A-4>", "<Cmd>BufferLineGoToBuffer 4<CR>", {silent = true, desc = "Go to buffer 4"})
    map("n", "<A-5>", "<Cmd>BufferLineGoToBuffer 5<CR>", {silent = true, desc = "Go to buffer 5"})
    map("n", "<A-6>", "<Cmd>BufferLineGoToBuffer 6<CR>", {silent = true, desc = "Go to buffer 6"})
    map("n", "<A-7>", "<Cmd>BufferLineGoToBuffer 7<CR>", {silent = true, desc = "Go to buffer 7"})
    map("n", "<A-8>", "<Cmd>BufferLineGoToBuffer 8<CR>", {silent = true, desc = "Go to buffer 8"})
    map("n", "<A-9>", "<Cmd>BufferLineGoToBuffer 9<CR>", {silent = true, desc = "Go to buffer 9"})
    map("n", "<A-0>", "<Cmd>BufferLineGoToBuffer -1<CR>", {silent = true, desc = "Go to last buffer"})
    
    map("n", "<A-p>", "<Cmd>BufferLineTogglePin<CR>", {silent = true, desc = "Pin/unpin buffer"})
    map("n", "<A-c>", "<Cmd>bdelete<CR>", {silent = true, desc = "Close buffer"})
    map("n", "<leader>bc", "<Cmd>bdelete<CR>", {silent = true, desc = "Close buffer"})
    map("n", "<leader>bC", "<Cmd>BufferLineCloseOthers<CR>", {silent = true, desc = "Close other buffers"})
    
    map("n", "<leader>fb", function()
      require("telescope.builtin").buffers({
        sort_mru = true,
        sort_lastused = true,
        initial_mode = "normal",
      })
    end, {silent = true, desc = "Find buffers"})
    
    -- Smart window navigation
    map("n", "<C-h>", function()
      local curr_win = vim.fn.winnr()
      vim.cmd("wincmd h")
      if curr_win == vim.fn.winnr() then
        vim.cmd("BufferLineCyclePrev")
      end
    end, {silent = true, desc = "Left window or prev buffer"})
    
    map("n", "<C-l>", function()
      local curr_win = vim.fn.winnr()
      vim.cmd("wincmd l")
      if curr_win == vim.fn.winnr() then
        vim.cmd("BufferLineCycleNext")
      end
    end, {silent = true, desc = "Right window or next buffer"})
  end
}
