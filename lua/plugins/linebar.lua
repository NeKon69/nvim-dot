return {
  "akinsho/bufferline.nvim",
  version = "*",
  dependencies = "nvim-tree/nvim-web-devicons",
  event = "VeryLazy",
  opts = {
    options = {
      mode = "buffers",
      themable = true,
      numbers = "buffer_id",
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
      diagnostics_indicator = function(count, level, diagnostics_dict, context)
        local icon = level:match("error") and " " or " "
        return " " .. icon .. count
      end,
      
      offsets = {
        {
          filetype = "NvimTree",
          text = "",
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
      
      separator_style = "thin",
      enforce_regular_tabs = false,
      always_show_bufferline = true,
      hover = {
        enabled = true,
        delay = 200,
        reveal = {"close"},
      },
      
      sort_by = "insert_after_current",
    },
  },
  
  config = function(_, opts)
    require("bufferline").setup(opts)
    
    -- Keybindings (same as barbar)
    local map = vim.keymap.set
    local opts_map = {noremap = true, silent = true}
    
    map("n", "<A-,>", "<Cmd>BufferLineCyclePrev<CR>", opts_map)
    map("n", "<A-.>", "<Cmd>BufferLineCycleNext<CR>", opts_map)
    map("n", "<A-<>", "<Cmd>BufferLineMovePrev<CR>", opts_map)
    map("n", "<A->>", "<Cmd>BufferLineMoveNext<CR>", opts_map)
    
    map("n", "<A-1>", "<Cmd>BufferLineGoToBuffer 1<CR>", opts_map)
    map("n", "<A-2>", "<Cmd>BufferLineGoToBuffer 2<CR>", opts_map)
    map("n", "<A-3>", "<Cmd>BufferLineGoToBuffer 3<CR>", opts_map)
    map("n", "<A-4>", "<Cmd>BufferLineGoToBuffer 4<CR>", opts_map)
    map("n", "<A-5>", "<Cmd>BufferLineGoToBuffer 5<CR>", opts_map)
    map("n", "<A-6>", "<Cmd>BufferLineGoToBuffer 6<CR>", opts_map)
    map("n", "<A-7>", "<Cmd>BufferLineGoToBuffer 7<CR>", opts_map)
    map("n", "<A-8>", "<Cmd>BufferLineGoToBuffer 8<CR>", opts_map)
    map("n", "<A-9>", "<Cmd>BufferLineGoToBuffer 9<CR>", opts_map)
    map("n", "<A-0>", "<Cmd>BufferLineGoToBuffer -1<CR>", opts_map)
    
    map("n", "<A-p>", "<Cmd>BufferLineTogglePin<CR>", opts_map)
    map("n", "<A-c>", "<Cmd>bdelete<CR>", opts_map)
    map("n", "<leader>bc", "<Cmd>bdelete<CR>", opts_map)
    map("n", "<leader>bC", "<Cmd>BufferLineCloseOthers<CR>", opts_map)
    
    map("n", "<leader>fb", function()
      require("telescope.builtin").buffers({
        sort_mru = true,
        sort_lastused = true,
        initial_mode = "normal",
      })
    end, opts_map)
    
    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        local buffers = vim.fn.getbufinfo({buflisted = 1})
        table.sort(buffers, function(a, b)
          return a.lastused > b.lastused
        end)
        
        if buffers[i] then
          vim.api.nvim_set_current_buf(buffers[i].bufnr)
        end
      end, opts_map)
    end
  end
}
