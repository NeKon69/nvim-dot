return {
  "nvim-tree/nvim-tree.lua",
  version = "*",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
    {
      "stevearc/dressing.nvim",
      opts = {
        input = {
          start_mode = "insert",
          relative = "cursor",
          border = "rounded",
          min_width = { 30, 0.3 },
          max_width = { 140, 0.9 },
          win_options = {
            winblend = 0,
            wrap = false,
          },
          get_config = function(opts)
            if opts.default and opts.prompt and opts.prompt:match("Rename") then
              local filename = opts.default
              local is_file = filename:match("%.%w+$")
              
              if is_file then
                vim.schedule(function()
                  local dot_pos = filename:reverse():find("%.")
                  if dot_pos then
                    local select_end = #filename - dot_pos - 1
                    vim.api.nvim_feedkeys(
                      vim.api.nvim_replace_termcodes("<Home><C-o>v" .. select_end .. "l", true, false, true),
                      "n",
                      false
                    )
                  end
                end)
              end
            end
          end,
        },
      },
    },
  },
  config = function()
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1

    local log_file = vim.fn.stdpath("cache") .. "/nvim_tree_errors.log"
    
    local function log_error(msg)
      local f = io.open(log_file, "a")
      if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. " | ERROR | " .. msg .. "\n")
        f:close()
      end
    end
    
    local function find_git_root(path)
      path = path or vim.fn.getcwd()
      local current = path
      while current ~= "/" do
        if vim.fn.isdirectory(current .. "/.git") == 1 then
          return current
        end
        current = vim.fn.fnamemodify(current, ":h")
      end
      return nil
    end
    
    local function get_project_nvim_dir()
      local git_root = find_git_root()
      if not git_root then return nil end
      
      local nvim_dir = git_root .. "/.nvim"
      
      if vim.fn.isdirectory(nvim_dir) == 0 then
        vim.fn.mkdir(nvim_dir, "p")
      end
      
      return nvim_dir
    end
    
    local function get_state_file_path()
      local nvim_dir = get_project_nvim_dir()
      if nvim_dir then
        return nvim_dir .. "/tree-state"
      end
      return nil
    end
    
    local function get_relative_path(abs_path)
      local git_root = find_git_root()
      if not git_root then return abs_path end
      
      if abs_path:match("^" .. vim.pesc(git_root)) then
        return abs_path:sub(#git_root + 2)
      end
      return abs_path
    end
    
    local function get_absolute_path(rel_path)
      local git_root = find_git_root()
      if not git_root then return rel_path end
      if rel_path:match("^/") then return rel_path end
      return git_root .. "/" .. rel_path
    end

    local restore_pending = false

    local function collect_open_dirs(node, open_paths)
      if node.open and node.type == "directory" then
        local rel_path = get_relative_path(node.absolute_path)
        table.insert(open_paths, rel_path)
      end
      if node.nodes then
        for _, child in ipairs(node.nodes) do
          collect_open_dirs(child, open_paths)
        end
      end
    end

    local function save_state()
      local state_file = get_state_file_path()
      if not state_file then return end
      
      local ok_core, core = pcall(require, "nvim-tree.core")
      if not ok_core then return end

      local explorer = core.get_explorer()
      if not explorer or not explorer.nodes then return end

      local open_dirs = {}
      for _, node in ipairs(explorer.nodes) do
        collect_open_dirs(node, open_dirs)
      end

      if #open_dirs == 0 then return end

      local f = io.open(state_file, "w")
      if f then
        local timestamp = os.time()
        f:write("-- nvim-tree state | last updated: " .. os.date("%Y-%m-%d %H:%M:%S", timestamp) .. "\n")
        f:write("return {\n")
        f:write("  timestamp = " .. timestamp .. ",\n")
        f:write("  open_dirs = {\n")
        for _, dir in ipairs(open_dirs) do
          f:write(string.format("    %q,\n", dir))
        end
        f:write("  },\n")
        f:write("}\n")
        f:close()
      else
        log_error("Failed to write state file: " .. state_file)
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
      local state_file = get_state_file_path()
      if not state_file then return end
      
      local ok, state_data = pcall(dofile, state_file)
      if not ok or type(state_data) ~= "table" or not state_data.open_dirs then 
        return 
      end
      
      local open_dirs = state_data.open_dirs
      if #open_dirs == 0 then return end

      local abs_dirs = {}
      for _, rel_dir in ipairs(open_dirs) do
        local abs_dir = get_absolute_path(rel_dir)
        if vim.fn.isdirectory(abs_dir) == 1 then
          table.insert(abs_dirs, abs_dir)
        end
      end

      table.sort(abs_dirs, function(a, b)
        local depth_a = select(2, a:gsub("/", ""))
        local depth_b = select(2, b:gsub("/", ""))
        return depth_a < depth_b
      end)

      local api = require("nvim-tree.api")

      local function expand_next(index)
        if index > #abs_dirs then return end

        local dir = abs_dirs[index]
        
        vim.defer_fn(function()
          local ok_core, core = pcall(require, "nvim-tree.core")
          if not ok_core then 
            log_error("Failed to get nvim-tree.core during restore")
            return 
          end

          local explorer = core.get_explorer()
          if not explorer or not explorer.nodes then return end

          local result = expand_node_by_path(explorer.nodes, dir)
          if result == true then 
            pcall(api.tree.reload)
          end

          expand_next(index + 1)
        end, 5)
      end

      vim.defer_fn(function()
        expand_next(1)
      end, 50)
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
        end, 150)
      end, 100)
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

      local function telescope_find_files()
        local node = api.tree.get_node_under_cursor()
        local path = node.absolute_path
        
        if node.type == "file" then
          path = vim.fn.fnamemodify(path, ":h")
        end
        
        require("telescope.builtin").find_files({
          cwd = path,
          prompt_title = "Find Files in " .. vim.fn.fnamemodify(path, ":t"),
        })
      end

      local function telescope_live_grep()
        local node = api.tree.get_node_under_cursor()
        local path = node.absolute_path
        
        if node.type == "file" then
          path = vim.fn.fnamemodify(path, ":h")
        end
        
        require("telescope.builtin").live_grep({
          cwd = path,
          prompt_title = "Grep in " .. vim.fn.fnamemodify(path, ":t"),
        })
      end

      local function telescope_find_directory()
        local pickers = require("telescope.pickers")
        local finders = require("telescope.finders")
        local conf = require("telescope.config").values
        local actions = require("telescope.actions")
        local action_state = require("telescope.actions.state")
        
        local node = api.tree.get_node_under_cursor()
        local current_path = node.absolute_path
        if node.type == "file" then
          current_path = vim.fn.fnamemodify(current_path, ":h")
        end
        
        local project_root = vim.fn.getcwd()
        
        pickers.new({}, {
          prompt_title = "🗂️  Find Directory",
          finder = finders.new_oneshot_job(
            vim.tbl_flatten({
              "fd",
              "--type", "d",
              "--hidden",
              "--follow",
              "--exclude", ".git",
              "--base-directory", project_root,
            }),
            {
              cwd = project_root,
              entry_maker = function(entry)
                return {
                  value = entry,
                  display = entry,
                  ordinal = entry,
                  path = project_root .. "/" .. entry,
                }
              end,
            }
          ),
          sorter = conf.generic_sorter({}),
          attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
              actions.close(prompt_bufnr)
              local selection = action_state.get_selected_entry()
              
              if selection then
                local target_path = selection.path
                
                if not api.tree.is_visible() then
                  api.tree.open()
                end
                
                vim.defer_fn(function()
                  api.tree.find_file(target_path)
                  
                  vim.defer_fn(function()
                    api.node.open.edit()
                  end, 10)
                end, 30)
              end
            end)
            return true
          end,
        }):find()
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
      vim.keymap.set("n", "r", api.fs.rename, opts("✏️  Rename"))
      vim.keymap.set("n", "e", api.fs.rename_basename, opts("✏️  Rename: Basename"))
      vim.keymap.set("n", "<C-r>", api.fs.rename_sub, opts("✏️  Rename: Omit Filename"))
      
      vim.keymap.set("n", "c", api.fs.copy.node, opts("📋 Copy"))
      vim.keymap.set("n", "x", api.fs.cut, opts("✂️  Cut"))
      vim.keymap.set("n", "p", api.fs.paste, opts("📌 Paste"))
      vim.keymap.set("n", "y", api.fs.copy.filename, opts("📋 Copy Name"))
      vim.keymap.set("n", "Y", api.fs.copy.relative_path, opts("📋 Copy Relative Path"))
      vim.keymap.set("n", "gy", api.fs.copy.absolute_path, opts("📋 Copy Absolute Path"))

      vim.keymap.set("n", "f", telescope_find_files, opts("🔭 Telescope: Find Files"))
      vim.keymap.set("n", "F", telescope_live_grep, opts("🔭 Telescope: Live Grep"))
      vim.keymap.set("n", "<C-f>", telescope_find_directory, opts("🔭🗂️  Telescope: Find Directory"))
      vim.keymap.set("n", "S", api.tree.search_node, opts("🔍 Search Node"))
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
        timer:start(1500, 1500, vim.schedule_wrap(function()
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
        end, 50)
      end,
    })

    vim.keymap.set("n", "<leader>e", function()
      require("nvim-tree.api").tree.toggle({ float = true })
      
      if restore_pending then
        vim.defer_fn(function()
          restore_state_internal()
          restore_pending = false
        end, 100)
      end
    end, { desc = "Toggle file explorer (float)" })
  end,
}
