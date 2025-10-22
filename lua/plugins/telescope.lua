return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    local actions = require("telescope.actions")
    local action_state = require("telescope.actions.state")
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local conf = require("telescope.config").values
    local entry_display = require("telescope.pickers.entry_display")
    local sorters = require("telescope.sorters")
    
    -- ============ ЛОГИРОВАНИЕ ============
    local log_file = vim.fn.stdpath("cache") .. "/smart_picker.log"
    
    local function log(msg)
      local f = io.open(log_file, "a")
      if f then
        f:write(os.date("%Y-%m-%d %H:%M:%S") .. " | " .. msg .. "\n")
        f:close()
      end
    end
    
    local function clear_log()
      local f = io.open(log_file, "w")
      if f then f:close() end
    end
    
    -- ============ GIT ROOT DETECTION ============
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
    
    -- ============ PATH HELPERS ============
    local function get_relative_path(abs_path)
      local git_root = find_git_root()
      if not git_root then return abs_path end
      
      if abs_path:match("^" .. vim.pesc(git_root)) then
        local rel = abs_path:sub(#git_root + 2)
        return rel
      end
      return abs_path
    end
    
    local function get_absolute_path(rel_path)
      local git_root = find_git_root()
      if not git_root then return rel_path end
      if rel_path:match("^/") then return rel_path end
      return git_root .. "/" .. rel_path
    end
    
    -- ============ РАБОТА С .history ============
    local function get_history_path()
      local git_root = find_git_root()
      if git_root then
        return git_root .. "/.history"
      end
      return nil
    end
    
    local function read_history()
      local history_path = get_history_path()
      if not history_path then
        return {}
      end
      
      local f = io.open(history_path, "r")
      if not f then
        return {}
      end
      
      local entries = {}
      local count = 0
      for line in f:lines() do
        count = count + 1
        if count > 1000 then break end
        
        local timestamp, filepath = line:match("^(%d+)|(.+)$")
        if timestamp and filepath then
          local abs_path = get_absolute_path(filepath)
          if vim.fn.filereadable(abs_path) == 1 then
            table.insert(entries, {
              timestamp = tonumber(timestamp),
              path = abs_path,
              relative_path = filepath,
              original_index = #entries + 1
            })
          end
        end
      end
      f:close()
      
      log("LOADED: " .. #entries .. " entries")
      return entries
    end
    
    local function write_to_history(filepath)
      local history_path = get_history_path()
      if not history_path then return end
      
      local git_root = find_git_root()
      if not git_root then return end
      
      local abs_path = vim.fn.fnamemodify(filepath, ":p")
      if not abs_path:match("^" .. vim.pesc(git_root)) then
        return
      end
      
      local rel_path = get_relative_path(abs_path)
      local timestamp = os.time()
      local entry = timestamp .. "|" .. rel_path
      
      local existing = {}
      local f = io.open(history_path, "r")
      if f then
        for line in f:lines() do
          local ts, path = line:match("^(%d+)|(.+)$")
          if path and path ~= rel_path then
            table.insert(existing, line)
          end
        end
        f:close()
      end
      
      f = io.open(history_path, "w")
      if f then
        f:write(entry .. "\n")
        for _, line in ipairs(existing) do
          f:write(line .. "\n")
        end
        f:close()
      end
    end
    
    -- ============ ФОРМАТИРОВАНИЕ ВРЕМЕНИ ============
    local function format_time(timestamp)
      local diff = os.time() - timestamp
      
      if diff < 60 then
        return string.format("%ds", diff)
      elseif diff < 3600 then
        return string.format("%dm", math.floor(diff / 60))
      elseif diff < 86400 then
        return string.format("%dh", math.floor(diff / 3600))
      elseif diff < 604800 then
        return string.format("%dd", math.floor(diff / 86400))
      else
        return string.format("%dw", math.floor(diff / 604800))
      end
    end
    
    -- ============ ПАРСИНГ ЗАПРОСОВ ============
    local function parse_query(query)
      if query == "" then
        return { type = "all" }
      end
      
      local parts = {}
      local current = ""
      for i = 1, #query do
        local char = query:sub(i, i)
        if char == "&" or char == "|" then
          if current ~= "" then
            table.insert(parts, current)
            table.insert(parts, char)
            current = ""
          end
        else
          current = current .. char
        end
      end
      if current ~= "" then
        table.insert(parts, current)
      end
      
      local parsed = {}
      for _, part in ipairs(parts) do
        if part == "&" or part == "|" then
          table.insert(parsed, { type = "operator", value = part })
        else
          local num = tonumber(part)
          if num and part:match("^%d+$") then
            table.insert(parsed, { type = "index", value = num })
          elseif part:match("^%d+[smhdw]$") then
            local value = tonumber(part:match("^(%d+)"))
            local unit = part:match("([smhdw])$")
            table.insert(parsed, { type = "time", value = value, unit = unit })
          else
            table.insert(parsed, { type = "text", value = part })
          end
        end
      end
      
      return { type = "parsed", parts = parsed }
    end
    
    -- ============ ФИЛЬТРАЦИЯ ============
    local function filter_by_index(entries, index, range)
      range = range or 10
      local results = {}
      local start_idx = math.max(1, index - range)
      local end_idx = math.min(#entries, index + range)
      
      for i = start_idx, end_idx do
        table.insert(results, entries[i])
      end
      
      log("  filter_by_index(" .. index .. "): " .. #results .. " results [#" .. start_idx .. "-#" .. end_idx .. "]")
      return results
    end
    
    local function filter_by_time(entries, value, unit)
      local multiplier = {s = 1, m = 60, h = 3600, d = 86400, w = 604800}
      local target_time = os.time() - (value * multiplier[unit])
      
      local closest_idx = 1
      local min_diff = math.abs(entries[1].timestamp - target_time)
      
      for i, entry in ipairs(entries) do
        local diff = math.abs(entry.timestamp - target_time)
        if diff < min_diff then
          min_diff = diff
          closest_idx = i
        end
      end
      
      local age_diff = os.time() - entries[closest_idx].timestamp
      log("  filter_by_time(" .. value .. unit .. "): target=" .. value .. unit .. 
          ", closest is #" .. closest_idx .. " (age=" .. math.floor(age_diff/86400) .. "d)")
      return filter_by_index(entries, closest_idx, 10), closest_idx
    end
    
    local function filter_by_text(entries, text)
      local results = {}
      
      for _, entry in ipairs(entries) do
        if entry.relative_path:lower():find(text:lower(), 1, true) then
          table.insert(results, entry)
        end
      end
      
      table.sort(results, function(a, b)
        local a_pos = a.relative_path:lower():find(text:lower(), 1, true)
        local b_pos = b.relative_path:lower():find(text:lower(), 1, true)
        return a_pos < b_pos
      end)
      
      local filtered = {}
      for i = 1, math.min(20, #results) do
        table.insert(filtered, results[i])
      end
      
      log("  filter_by_text('" .. text .. "'): " .. #filtered .. " results")
      return filtered
    end
    
    local function intersect_results(set1, set2)
      local paths = {}
      for _, entry in ipairs(set1) do
        paths[entry.path] = entry
      end
      
      local result = {}
      for _, entry in ipairs(set2) do
        if paths[entry.path] then
          table.insert(result, entry)
        end
      end
      
      log("  intersect: " .. #result .. " results")
      return result
    end
    
    local function union_results(set1, set2)
      local paths = {}
      local result = {}
      
      for _, entry in ipairs(set1) do
        if not paths[entry.path] then
          paths[entry.path] = true
          table.insert(result, entry)
        end
      end
      
      for _, entry in ipairs(set2) do
        if not paths[entry.path] then
          paths[entry.path] = true
          table.insert(result, entry)
        end
      end
      
      log("  union: " .. #result .. " results")
      return result
    end
    
    
-- ============ ПРИМЕНЕНИЕ ЗАПРОСА (ИСПРАВЛЕНО) ============
local function apply_query(entries, parsed)
  local default_highlight = {
    highlight_index = false,
    highlight_time = false,
    text_patterns = {},
    target_index = nil
  }
  
  if parsed.type == "all" then
    return entries, nil, default_highlight
  end
  
  if #parsed.parts == 0 then
    return entries, nil, default_highlight
  end
  
  local result = nil
  local pending_op = nil
  local highlight_info = {
    highlight_index = false,
    highlight_time = false,
    text_patterns = {},
    target_index = nil
  }
  
  local all_targets = {}
  local time_targets = {}  -- Отдельно храним time targets для tiebreaker
  
  for i, part in ipairs(parsed.parts) do
    if part.type == "operator" then
      pending_op = part.value
    else
      local current_result = nil
      local current_target = nil
      
      if part.type == "index" then
        current_result = filter_by_index(entries, part.value)
        current_target = part.value
        table.insert(all_targets, { type = "index", value = part.value })
        
        if not highlight_info.highlight_index then
          highlight_info.highlight_index = true
        end
        
      elseif part.type == "time" then
        current_result, current_target = filter_by_time(entries, part.value, part.unit)
        table.insert(all_targets, { type = "time", value = current_target })
        table.insert(time_targets, current_target)  -- Запоминаем для tiebreaker
        
        if not highlight_info.highlight_time then
          highlight_info.highlight_time = true
        end
        
      elseif part.type == "text" then
        current_result = filter_by_text(result or entries, part.value)
        table.insert(highlight_info.text_patterns, part.value)
      end
      
      if result == nil then
        result = current_result
      elseif pending_op == "&" then
        result = intersect_results(result, current_result)
        pending_op = nil
      elseif pending_op == "|" then
        result = union_results(result, current_result)
        pending_op = nil
      end
    end
  end
  
  -- УНИВЕРСАЛЬНЫЙ BEST MATCH с tiebreaker по времени
  if #all_targets > 0 and result and #result > 0 then
    log(">>> FINDING BEST MATCH: " .. #all_targets .. " targets")
    
    local best_entry = nil
    local best_score = math.huge
    local best_time_dist = math.huge
    
    for _, entry in ipairs(result) do
      local total_score = 0
      local time_dist = 0
      
      for _, target in ipairs(all_targets) do
        total_score = total_score + math.abs(entry.original_index - target.value)
      end
      
      -- Считаем расстояние до времени для tiebreaker
      if #time_targets > 0 then
        for _, time_target in ipairs(time_targets) do
          time_dist = time_dist + math.abs(entry.original_index - time_target)
        end
      end
      
      log("  #" .. entry.original_index .. ": score=" .. total_score .. 
          (#time_targets > 0 and (", time_dist=" .. time_dist) or ""))
      
      -- Выбираем файл с меньшим score, при равном - с меньшим time_dist
      if total_score < best_score or 
         (total_score == best_score and time_dist < best_time_dist) then
        best_score = total_score
        best_time_dist = time_dist
        best_entry = entry
      end
    end
    
    if best_entry then
      highlight_info.target_index = best_entry.original_index
      log(">>> BEST MATCH: #" .. best_entry.original_index .. 
          " (score=" .. best_score .. 
          (#time_targets > 0 and (", time_dist=" .. best_time_dist) or "") .. ")")
    end
  end
  
  log("HIGHLIGHT: index=" .. tostring(highlight_info.highlight_index) .. 
      ", time=" .. tostring(highlight_info.highlight_time) .. 
      ", target=#" .. tostring(highlight_info.target_index))
  
  -- Для курсора используем BEST MATCH, а не первую цель!
  local cursor_target = highlight_info.target_index
  
  return result or entries, cursor_target, highlight_info
end
    
    -- ============ SMART PICKER ============
    local function smart_file_picker()
      clear_log()
      log("=== SMART PICKER STARTED ===")
      
      local history_entries = read_history()
      
      if #history_entries == 0 then
        builtin.find_files()
        return
      end
      
      local max_num = #history_entries
      local num_width = max_num < 1000 and 3 or 4
      
      local current_highlight_info = {
        highlight_index = false,
        highlight_time = false,
        text_patterns = {},
        target_index = nil
      }
      
      local displayer = entry_display.create {
        separator = "  ",
        items = {
          { width = num_width + 1 },
          { width = 5 },
          { remaining = true },
        },
      }
      
      local function make_display(entry)
        local num_str = string.format("#%0" .. num_width .. "d", entry.original_index)
        local time_str = format_time(entry.value.timestamp)
        local path_str = entry.value.relative_path
        
        local should_highlight_num = current_highlight_info.highlight_index and 
                                      (current_highlight_info.target_index == entry.original_index)
        local should_highlight_time = current_highlight_info.highlight_time and 
                                       (current_highlight_info.target_index == entry.original_index)
        
        return displayer {
          { num_str, should_highlight_num and "TelescopeMatching" or "TelescopeResultsNumber" },
          { time_str, should_highlight_time and "TelescopeMatching" or "TelescopeResultsComment" },
          path_str,
        }
      end
      
      local empty_sorter = sorters.Sorter:new {
        scoring_function = function() return 0 end,
        highlighter = function(_, prompt, display)
          local highlights = {}
          
          for _, pattern in ipairs(current_highlight_info.text_patterns) do
            local start_pos, end_pos = display:lower():find(pattern:lower(), 1, true)
            if start_pos then
              table.insert(highlights, {
                start = start_pos,
                finish = end_pos,
              })
            end
          end
          
          return highlights
        end,
      }
      
      local picker = pickers.new({}, {
        prompt_title = "Smart File Picker",
        finder = finders.new_table {
          results = history_entries,
          entry_maker = function(entry)
            return {
              value = entry,
              display = make_display,
              ordinal = "",
              path = entry.path,
              original_index = entry.original_index,
            }
          end,
        },
        sorter = empty_sorter,
        attach_mappings = function(prompt_bufnr, map)
          local function refresh_picker(new_results, move_to_idx, new_highlight_info)
            current_highlight_info = new_highlight_info or {
              highlight_index = false,
              highlight_time = false,
              text_patterns = {},
              target_index = nil
            }
            
            local current_picker = action_state.get_current_picker(prompt_bufnr)
            current_picker:refresh(
              finders.new_table {
                results = new_results,
                entry_maker = function(entry)
                  return {
                    value = entry,
                    display = make_display,
                    ordinal = "",
                    path = entry.path,
                    original_index = entry.original_index,
                  }
                end,
              },
              { reset_prompt = false }
            )
            
            if move_to_idx then
              vim.schedule(function()
                vim.schedule(function()
                  local manager = current_picker.manager
                  for i = 0, manager:num_results() - 1 do
                    local entry = manager:get_entry(i)
                    if entry and entry.original_index == move_to_idx then
                      current_picker:set_selection(math.max(0, i - 1))
                      return
                    end
                  end
                end)
              end)
            end
          end
          
          vim.api.nvim_create_autocmd("TextChangedI", {
            buffer = prompt_bufnr,
            callback = function()
              local current_picker = action_state.get_current_picker(prompt_bufnr)
              local prompt = current_picker:_get_prompt()
              
              log("=== PROMPT: '" .. prompt .. "' ===")
              
              local parsed = parse_query(prompt)
              local filtered, target, highlight_info = apply_query(history_entries, parsed)
              
              refresh_picker(filtered, target, highlight_info)
            end,
          })
          
          return true
        end,
      })
      
      picker:find()
    end
    
    -- ============ BufEnter HOOK ============
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "*",
      callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        if bufname ~= "" and vim.fn.filereadable(bufname) == 1 then
          write_to_history(bufname)
        end
      end,
    })
    
    -- ============ TELESCOPE SETUP ============
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "🔍 Telescope: Find Files" })
    vim.keymap.set("n", "<leader>fs", smart_file_picker, { desc = "📜 Smart File Picker (History)" })
    
    require("telescope").setup{
      defaults = {
        layout_strategy = "vertical",
        sorting_strategy = "ascending",
        selection_strategy = "follow",
        layout_config = {
          vertical = {
            prompt_position = "top",
            preview_position = "bottom",
            width = 0.54,
            height = 0.38,
            mirror = true,
            preview_cutoff = 0,
          },
        },
        border = true,
        borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
        color_devicons = true,
        path_display = { "truncate" },
        prompt_title = "Search",
        results_title = "Files",
        preview_title = "Preview",
      },
    }
    
    vim.api.nvim_set_hl(0, "TelescopeBorder", { fg = "#5daeff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopePromptBorder", { fg = "#b464ff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeResultsBorder", { fg = "#cf55ff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopePreviewBorder", { fg = "#fa6fff", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeSelection", { fg = "#ff5555", bg = "NONE" })
    vim.api.nvim_set_hl(0, "TelescopeMatching", { fg = "#ffea00", bg = "NONE" })
  end,
}
