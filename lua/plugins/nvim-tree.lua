return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local save_file = vim.fn.stdpath("data") .. "/nvim-tree-state.lua"
    local restore_pending = false

    local function collect_open_dirs(node, open_paths)
      if node.open and node.type == "directory" then
        table.insert(open_paths, node.absolute_path)
      end
      if node.nodes then
        for _, child in ipairs(node.nodes) do
          collect_open_dirs(child, open_paths)
        end
      end
    end

    local function save_state()
      local ok_core, core = pcall(require, "nvim-tree.core")
      if not ok_core then return end

      local explorer = core.get_explorer()
      if not explorer or not explorer.nodes then return end

      local open_dirs = {}
      for _, node in ipairs(explorer.nodes) do
        collect_open_dirs(node, open_dirs)
      end

      local f = io.open(save_file, "w")
      if f then
        f:write("return " .. vim.inspect(open_dirs))
        f:close()
      end
    end

    local function expand_node_by_path(nodes, target_path)
      for _, node in ipairs(nodes) do
        if node.absolute_path == target_path and node.type == "directory" then
          if not node.open then
            node.open = true
            node.has_children = true
            return true
          end
          return false
        end
        if node.nodes and #node.nodes > 0 then
          local result = expand_node_by_path(node.nodes, target_path)
          if result ~= nil then return result end
        end
      end
      return nil
    end

    local function restore_state_internal()
      local ok, open_dirs = pcall(dofile, save_file)
      if not ok or type(open_dirs) ~= "table" or #open_dirs == 0 then return end

      table.sort(open_dirs, function(a, b)
        local depth_a = select(2, a:gsub("/", ""))
        local depth_b = select(2, b:gsub("/", ""))
        return depth_a < depth_b
      end)

      local api = require("nvim-tree.api")

      local function expand_next(index)
        if index > #open_dirs then return end

        local dir = open_dirs[index]
        
        vim.defer_fn(function()
          local ok_core, core = pcall(require, "nvim-tree.core")
          if not ok_core then return end

          local explorer = core.get_explorer()
          if not explorer or not explorer.nodes then return end

          local result = expand_node_by_path(explorer.nodes, dir)
          if result == true then pcall(api.tree.reload) end

          expand_next(index + 1)
        end, 20)
      end

      vim.defer_fn(function()
        expand_next(1)
      end, 200)
    end

    local function restore_state_background()
      local api = require("nvim-tree.api")
      restore_pending = true
      
      vim.cmd("NvimTreeOpen")
      
      vim.defer_fn(function()
        restore_state_internal()
        vim.defer_fn(function()
          api.tree.close()
          restore_pending = false
        end, 500)
      end, 300)
    end

    local function smart_rename(rename_fn)
      return function()
        local node = require("nvim-tree.api").tree.get_node_under_cursor()
        if not node then return end

        local current_name = node.name
        local is_dir = node.type == "directory"
        
        local basename_end = current_name:find("%.[^%.]+$") or #current_name + 1
        
        local original_input = vim.ui.input
        vim.ui.input = function(opts, on_confirm)
          vim.ui.input = original_input
          
          opts.default = opts.default or current_name
          
          original_input(opts, function(new_name)
            if on_confirm then
              on_confirm(new_name)
            end
          end)
          
          vim.defer_fn(function()
            local mode = vim.fn.mode()
            if mode == "c" then
              if not is_dir and basename_end > 1 then
                local pos = basename_end - 1
                vim.fn.setcmdpos(pos + 1)
              end
            end
          end, 10)
        end
        
        rename_fn()
      end
    end

    local function on_attach(bufnr)
      local api = require("nvim-tree.api")

      local function opts(desc)
        return {
          desc = "nvim-tree: " .. desc,
          buffer = bufnr,
          noremap = true,
          silent = true,
          nowait = true,
        }
      end

      vim.keymap.set("n", "<CR>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "o", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Close Directory"))
      vim.keymap.set("n", "<BS>", api.node.navigate.parent_close, opts("Close Directory"))
      
      vim.keymap.set("n", "v", api.node.open.vertical, opts("Open: Vertical Split"))
      vim.keymap.set("n", "s", api.node.open.horizontal, opts("Open: Horizontal Split"))
      vim.keymap.set("n", "t", api.node.open.tab, opts("Open: New Tab"))

      vim.keymap.set("n", "a", api.fs.create, opts("➕ Create File/Directory"))
      vim.keymap.set("n", "d", api.fs.remove, opts("🗑️  Delete"))
      vim.keymap.set("n", "D", api.fs.trash, opts("🗑️  Trash"))
      vim.keymap.set("n", "r", smart_rename(api.fs.rename), opts("✏️  Rename (Smart)"))
      vim.keymap.set("n", "e", smart_rename(api.fs.rename_basename), opts("✏️  Rename: Basename (Smart)"))
      vim.keymap.set("n", "<C-r>", smart_rename(api.fs.rename_sub), opts("✏️  Rename: Omit Filename (Smart)"))
      
      vim.keymap.set("n", "c", api.fs.copy.node, opts("📋 Copy"))
      vim.keymap.set("n", "x", api.fs.cut, opts("✂️  Cut"))
      vim.keymap.set("n", "p", api.fs.paste, opts("📌 Paste"))
      vim.keymap.set("n", "y", api.fs.copy.filename, opts("📋 Copy Name"))
      vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("📋 Copy Relative Path"))
      vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("📋 Copy Absolute Path"))

      vim.keymap.set("n", "f", api.live_filter.start, opts("🔍 Filter"))
      vim.keymap.set("n", "F", api.live_filter.clear, opts("🔍 Clear Filter"))
      vim.keymap.set("n", "S", api.tree.search_node, opts("🔍 Search"))
      vim.keymap.set("n", "<C-k>", api.node.show_info_popup, opts("ℹ️  Info"))
      
      vim.keymap.set("n", "R", api.tree.reload, opts("🔄 Refresh"))
      vim.keymap.set("n", "E", api.tree.expand_all, opts("📂 Expand All"))
      vim.keymap.set("n", "W", api.tree.collapse_all, opts("📁 Collapse All"))
      vim.keymap.set("n", "-", api.tree.change_root_to_parent, opts("⬆️  Up Directory"))
      vim.keymap.set("n", "<C-]>", api.tree.change_root_to_node, opts("💿 CD"))

      vim.keymap.set("n", "H", api.tree.toggle_hidden_filter, opts("👁️  Toggle Dotfiles"))
      vim.keymap.set("n", "I", api.tree.toggle_gitignore_filter, opts("🔀 Toggle Git Ignore"))
      vim.keymap.set("n", "B", api.tree.toggle_no_buffer_filter, opts("🗂️  Toggle No Buffer"))
      
      vim.keymap.set("n", "q", api.tree.close, opts("❌ Close"))
      vim.keymap.set("n", "g?", api.tree.toggle_help, opts("❓ Help"))
      vim.keymap.set("n", "<Tab>", api.node.open.preview, opts("👁️  Preview"))
      vim.keymap.set("n", "K", api.node.navigate.sibling.first, opts("⬆️  First Sibling"))
      vim.keymap.set("n", "J", api.node.navigate.sibling.last, opts("⬇️  Last Sibling"))
      vim.keymap.set("n", ">", api.node.navigate.sibling.next, opts("➡️  Next Sibling"))
      vim.keymap.set("n", "<", api.node.navigate.sibling.prev, opts("⬅️  Prev Sibling"))

      vim.keymap.set("n", "m", api.marks.toggle, opts("🔖 Toggle Bookmark"))
      vim.keymap.set("n", "bd", api.marks.bulk.delete, opts("🗑️  Delete Bookmarked"))
      vim.keymap.set("n", "bt", api.marks.bulk.trash, opts("🗑️  Trash Bookmarked"))
      vim.keymap.set("n", "bmv", api.marks.bulk.move, opts("📦 Move Bookmarked"))

      vim.keymap.set("n", "[c", api.node.navigate.git.prev, opts("⬅️  Prev Git"))
      vim.keymap.set("n", "]c", api.node.navigate.git.next, opts("➡️  Next Git"))

      vim.keymap.set("n", "[e", api.node.navigate.diagnostics.prev, opts("⬅️  Prev Diagnostic"))
      vim.keymap.set("n", "]e", api.node.navigate.diagnostics.next, opts("➡️  Next Diagnostic"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      hijack_netrw = false,
      hijack_directories = { enable = false },
      hijack_unnamed_buffer_when_opening = false,
      open_on_tab = false,
      sync_root_with_cwd = false,
      respect_buf_cwd = true,

      view = {
        float = {
          enable = true,
          quit_on_focus_loss = true,
          open_win_config = {
            relative = "editor",
            border = "rounded",
            width = math.floor(vim.o.columns * 0.5),
            height = math.floor(vim.o.lines * 0.6),
            row = math.floor((vim.o.lines - math.floor(vim.o.lines * 0.6)) / 2),
            col = math.floor((vim.o.columns - math.floor(vim.o.columns * 0.5)) / 2),
          },
        },
      },

      update_focused_file = {
        enable = true,
        update_root = true,
      },

      actions = {
        open_file = {
          quit_on_open = true,
          window_picker = { enable = true },
        },
      },

      renderer = {
        group_empty = true,
        icons = {
          glyphs = {
            git = {
              unstaged = "✗",
              staged = "✓",
              untracked = "★",
            },
          },
        },
      },
    })

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "NvimTree",
      callback = function()
        local timer = vim.loop.new_timer()
        timer:start(2000, 2000, vim.schedule_wrap(function()
          local api = require("nvim-tree.api")
          if api.tree.is_visible() then
            save_state()
          else
            timer:stop()
          end
        end))
      end,
    })

    vim.api.nvim_create_autocmd("VimEnter", {
      callback = function()
        vim.defer_fn(function()
          restore_state_background()
        end, 100)
      end,
    })

    vim.keymap.set("n", "<leader>e", function()
      require("nvim-tree.api").tree.toggle({ float = true })
      
      if restore_pending then
        vim.defer_fn(function()
          restore_state_internal()
          restore_pending = false
        end, 300)
      end
    end, { desc = "Toggle file explorer (float)" })
  end,
}
