return {
  "romgrk/barbar.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  event = "VeryLazy",
  opts = {
    animation = true,
    auto_hide = false,
    tabpages = true,
    clickable = true,
    
    exclude_ft = {"NvimTree"},
    exclude_name = {},
    
    icons = {
      buffer_index = true,
      buffer_number = false,
      button = "",
      diagnostics = {
        [vim.diagnostic.severity.ERROR] = {enabled = true, icon = " "},
        [vim.diagnostic.severity.WARN] = {enabled = true, icon = " "},
        [vim.diagnostic.severity.INFO] = {enabled = false},
        [vim.diagnostic.severity.HINT] = {enabled = false},
      },
      gitsigns = {
        added = {enabled = true, icon = "+"},
        changed = {enabled = true, icon = "~"},
        deleted = {enabled = true, icon = "-"},
      },
      filetype = {
        custom_colors = false,
        enabled = true,
      },
      separator = {left = "▎", right = ""},
      separator_at_end = true,
      modified = {button = "●"},
      pinned = {button = "", filename = true},
      preset = "default",
      alternate = {filetype = {enabled = false}},
      current = {buffer_index = true},
      inactive = {button = "×"},
      visible = {modified = {buffer_number = false}},
    },
    
    insert_at_end = false,
    insert_at_start = false,
    
    maximum_padding = 1,
    minimum_padding = 1,
    maximum_length = 30,
    minimum_length = 0,
    
    semantic_letters = true,
    no_name_title = "[No Name]",
    
    sidebar_filetypes = {
      NvimTree = true,
    },
  },
  
  init = function()
    local map = vim.keymap.set
    local opts = {noremap = true, silent = true}
    
    -- Buffer navigation
    map("n", "<A-,>", "<Cmd>BufferPrevious<CR>", opts)
    map("n", "<A-.>", "<Cmd>BufferNext<CR>", opts)
    map("n", "<A-<>", "<Cmd>BufferMovePrevious<CR>", opts)
    map("n", "<A->>", "<Cmd>BufferMoveNext<CR>", opts)
    
    -- Jump to buffer by number
    map("n", "<A-1>", "<Cmd>BufferGoto 1<CR>", opts)
    map("n", "<A-2>", "<Cmd>BufferGoto 2<CR>", opts)
    map("n", "<A-3>", "<Cmd>BufferGoto 3<CR>", opts)
    map("n", "<A-4>", "<Cmd>BufferGoto 4<CR>", opts)
    map("n", "<A-5>", "<Cmd>BufferGoto 5<CR>", opts)
    map("n", "<A-6>", "<Cmd>BufferGoto 6<CR>", opts)
    map("n", "<A-7>", "<Cmd>BufferGoto 7<CR>", opts)
    map("n", "<A-8>", "<Cmd>BufferGoto 8<CR>", opts)
    map("n", "<A-9>", "<Cmd>BufferGoto 9<CR>", opts)
    map("n", "<A-0>", "<Cmd>BufferLast<CR>", opts)
    
    -- Pin/unpin buffer
    map("n", "<A-p>", "<Cmd>BufferPin<CR>", opts)
    
    -- Close buffer
    map("n", "<A-c>", "<Cmd>BufferClose<CR>", opts)
    map("n", "<leader>bc", "<Cmd>BufferClose<CR>", opts)
    
    -- Close all but current
    map("n", "<leader>bC", "<Cmd>BufferCloseAllButCurrent<CR>", opts)
    
    -- Telescope integration for buffer search
    map("n", "<leader>fb", function()
      require("telescope.builtin").buffers({
        sort_mru = true,
        sort_lastused = true,
        initial_mode = "normal",
      })
    end, opts)
    
    -- MRU buffer jump (most recent 1-9)
    for i = 1, 9 do
      map("n", "<leader>" .. i, function()
        local buffers = vim.fn.getbufinfo({buflisted = 1})
        table.sort(buffers, function(a, b)
          return a.lastused > b.lastused
        end)
        
        if buffers[i] then
          vim.api.nvim_set_current_buf(buffers[i].bufnr)
        end
      end, opts)
    end
  end
}
