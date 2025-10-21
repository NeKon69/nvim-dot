return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.5",
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "🔍 Telescope: Find Files" })
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

    local log_file = vim.fn.stdpath("cache") .. "/smart_picker.log"
    local function log(msg)
      local f = io.open(log_file, "a")
      if f then
        f:write(os.date("%H:%M:%S") .. " | " .. tostring(msg) .. "\n")
        f:close()
      end
    end
    log("========== NVIM STARTED ==========")

    local function find_git_root(path)
      local current = path or vim.fn.getcwd()
      while current ~= "/" do
        if vim.fn.isdirectory(current .. "/.git") == 1 then
          return current
        end
        current = vim.fn.fnamemodify(current, ":h")
      end
      return nil
    end

    local function get_file_history_path(filepath)
      local git_root = find_git_root(vim.fn.fnamemodify(filepath, ":h"))
      if not git_root then
        return vim.fn.fnamemodify(filepath, ":.")
      end
      local rel_path = filepath:sub(#git_root + 2)
      local cmd = string.format(
        'git -C %s log --follow --name-only --format="" -- %s 2>/dev/null | head -n1',
        vim.fn.shellescape(git_root),
        vim.fn.shellescape(rel_path)
      )
      local handle = io.popen(cmd)
      if not handle then return rel_path end
      local original_name = handle:read("*l")
      handle:close()
      return original_name and original_name ~= "" and original_name or rel_path
    end

    local function read_history(history_file)
      local history = {}
      local file = io.open(history_file, "r")
      if not file then return history end
      for line in file:lines() do
        local timestamp_str, filepath = line:match("^(%d+)|(.+)$")
        if timestamp_str and filepath then
          local timestamp = tonumber(timestamp_str)
          if not history[filepath] or history[filepath] < timestamp then
            history[filepath] = timestamp
          end
        end
      end
      file:close()
      return history
    end

    local function append_to_history(history_file, filepath, timestamp)
      local file = io.open(history_file, "a")
      if not file then return end
      file:write(string.format("%d|%s\n", timestamp, filepath))
      file:close()
    end

    local function track_file_access(filepath)
      if not filepath or filepath == "" then return end
      filepath = vim.fn.fnamemodify(filepath, ":p")
      if filepath:match("%.history$") then return end
      local git_root = find_git_root(filepath)
      if not git_root then return end
      local history_file = git_root .. "/.history"
      local canonical_path = get_file_history_path(filepath)
      local timestamp = os.time()
      append_to_history(history_file, canonical_path, timestamp)
    end

    vim.api.nvim_create_autocmd({"BufReadPost", "BufNewFile"}, {
      callback = function(ev)
        if vim.bo[ev.buf].buftype == "" then
          local filepath = vim.api.nvim_buf_get_name(ev.buf)
          if filepath and filepath ~= "" then
            track_file_access(filepath)
          end
        end
      end,
    })

    local function smart_file_picker()
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local sorters = require("telescope.sorters")
      local Sorter = sorters.Sorter
      log("========== PICKER OPENED ==========")

      local function get_recent_files()
        local cwd = vim.fn.getcwd()
        local git_root = find_git_root(cwd)
        local history = {}
        if git_root then
          local history_file = git_root .. "/.history"
          history = read_history(history_file)
        end
        local all_files = {}
        for canonical, timestamp in pairs(history) do
          local full_path = git_root and (git_root .. "/" .. canonical) or canonical
          if vim.fn.filereadable(full_path) == 1 and not full_path:match("%.history$") then
            table.insert(all_files, {
              filename = full_path,
              display_name = vim.fn.fnamemodify(full_path, ":~:."),
              access_time = timestamp,
              canonical_path = canonical,
            })
          end
        end
        table.sort(all_files, function(a, b)
          local a_in_cwd = a.filename:find("^" .. vim.pesc(cwd), 1, false)
          local b_in_cwd = b.filename:find("^" .. vim.pesc(cwd), 1, false)
          if a_in_cwd and not b_in_cwd then return true end
          if b_in_cwd and not a_in_cwd then return false end
          return a.access_time > b.access_time
        end)
        for i = 1, #all_files do
          all_files[i].original_index = i
          log(string.format("FILE[%d]: %s (time=%d)", i, all_files[i].display_name, all_files[i].access_time))
        end
        log("Loaded " .. #all_files .. " files")
        return all_files
      end

      local all_files = get_recent_files()
      local parse_cache = {}
      local last_prompt = ""

      local function parse_query(query)
        if parse_cache[query] then
          return unpack(parse_cache[query])
        end
        local original_query = query
        query = query:gsub("%s+", "")
        local parts = {}
        for part in query:gmatch("[^&|]+") do
          if part ~= "" then
            table.insert(parts, part)
          end
        end
        local number_part = nil
        local time_part = nil
        local text_parts = {}
        for _, part in ipairs(parts) do
          if tonumber(part) and part:match("^%d+$") then
            number_part = tonumber(part)
          elseif part:match("^%d+[smhdw]$") then
            time_part = part
          else
            table.insert(text_parts, part)
          end
        end
        parse_cache[original_query] = {number_part, time_part, text_parts}
        return number_part, time_part, text_parts
      end

      local function find_time_match(time_query)
        local num, unit = time_query:match("^(%d+)([smhdw])$")
        if not num or not unit or #all_files == 0 then return nil end
        local now = os.time()
        local mult = {s=1, m=60, h=3600, d=86400, w=604800}
        local target_time = now - (tonumber(num) * mult[unit])
        local best_idx, best_diff = 1, math.abs(all_files[1].access_time - target_time)
        for i, f in ipairs(all_files) do
          local diff = math.abs(f.access_time - target_time)
          if diff < best_diff then
            best_idx, best_diff = i, diff
          end
        end
        return best_idx
      end

      local current_target_orig_idx = nil
      local current_target_type = nil
      local current_text_queries = {}
      local current_target_display_num = nil
      local current_target_time_str = nil
      local display_order = {}

      local function make_finder()
        return finders.new_table({
          results = all_files,
          entry_maker = function(entry)
            local now = os.time()
            local diff = now - entry.access_time
            local time_str
            if diff < 60 then
              time_str = string.format("%ds", diff)
            elseif diff < 3600 then
              time_str = string.format("%dm", math.floor(diff / 60))
            elseif diff < 86400 then
              time_str = string.format("%dh", math.floor(diff / 3600))
            elseif diff < 604800 then
              time_str = string.format("%dd", math.floor(diff / 86400))
            else
              time_str = string.format("%dw", math.floor(diff / 604800))
            end
            local display = string.format("#%-3d %-5s %s", entry.original_index, time_str, entry.display_name)
            return {
              value = entry,
              display = display,
              ordinal = entry.display_name,
              path = entry.filename,
              original_index = entry.original_index,
              time_str = time_str,
              access_time = entry.access_time,
              display_name = entry.display_name,
            }
          end,
        })
      end

      local fzy_sorter = sorters.get_fzy_sorter()
      local scored_results = {}

      local function smart_sorter()
        return Sorter:new{
          scoring_function = function(self, prompt, line, entry)
            if prompt ~= last_prompt then
              last_prompt = prompt
              scored_results = {}
              display_order = {}
              log(">>> PROMPT: '" .. prompt .. "'")
            end
            local number_part, time_part, text_parts = parse_query(prompt)
            if prompt ~= "" and #scored_results == 0 then
              log("PARSE: num=" .. tostring(number_part) .. " time=" .. tostring(time_part) .. " text=" .. vim.inspect(text_parts))
            end
            local target_orig_idx = nil
            if number_part and number_part > 0 and number_part <= #all_files then
              target_orig_idx = number_part
              current_target_type = "number"
              current_target_display_num = number_part
              if #scored_results == 0 then
                log("TARGET: original_index #" .. target_orig_idx .. " → " .. all_files[target_orig_idx].display_name)
              end
            elseif time_part then
              target_orig_idx = find_time_match(time_part)
              current_target_type = "time"
              if target_orig_idx and #scored_results == 0 then
                current_target_time_str = (function()
                  local now = os.time()
                  local diff = now - all_files[target_orig_idx].access_time
                  if diff < 60 then return string.format("%ds", diff)
                  elseif diff < 3600 then return string.format("%dm", math.floor(diff / 60))
                  elseif diff < 86400 then return string.format("%dh", math.floor(diff / 3600))
                  elseif diff < 604800 then return string.format("%dd", math.floor(diff / 86400))
                  else return string.format("%dw", math.floor(diff / 604800)) end
                end)()
                log("TARGET: original_index #" .. target_orig_idx .. " → " .. all_files[target_orig_idx].display_name .. " (time=" .. current_target_time_str .. ")")
              end
            else
              current_target_type = nil
              current_target_display_num = nil
              current_target_time_str = nil
            end
            current_target_orig_idx = target_orig_idx
            current_text_queries = text_parts
            local score
            if #text_parts > 0 then
              local combined_score = 0
              local has_match = true
              for _, text_query in ipairs(text_parts) do
                local text_score = fzy_sorter:scoring_function(text_query, line, entry)
                if text_score == -1 then
                  has_match = false
                  break
                end
                combined_score = combined_score + text_score
              end
              if not has_match then
                score = -1
              elseif target_orig_idx and entry.original_index == target_orig_idx then
                score = -10000
              else
                score = combined_score
              end
            else
              if target_orig_idx and entry.original_index == target_orig_idx then
                score = -10000
              else
                score = entry.original_index
              end
            end
            table.insert(scored_results, {
              file = entry.display,
              orig_idx = entry.original_index,
              score = score,
            })
            return score
          end,
          highlighter = function(self, prompt, display)
            if #scored_results > 0 and scored_results[1] then
              local sorted = vim.deepcopy(scored_results)
              table.sort(sorted, function(a, b)
                if a.score == -1 and b.score ~= -1 then return false
                elseif a.score ~= -1 and b.score == -1 then return true
                else return a.score < b.score end
              end)
              local visible = {}
              for i = 1, math.min(5, #sorted) do
                if sorted[i].score ~= -1 then
                  table.insert(visible, string.format("[%d] orig#%d score=%.1f %s", i, sorted[i].orig_idx, sorted[i].score, sorted[i].file))
                end
              end
              if #visible > 0 and visible[1] ~= (scored_results.last_logged or "") then
                log("DISPLAY_ORDER:")
                for _, v in ipairs(visible) do
                  log(" " .. v)
                end
                scored_results.last_logged = visible[1]
              end
            end
            local highlights = {}
            local display_orig_idx_str = display:match("^#(%d+)")
            local display_orig_idx = tonumber(display_orig_idx_str)
            if current_target_orig_idx and #current_text_queries == 0 then
              if display_orig_idx == current_target_orig_idx then
                if current_target_type == "number" and current_target_display_num then
                  local idx_pattern = "#" .. current_target_display_num
                  local start_pos = display:find(idx_pattern, 1, true)
                  if start_pos then
                    for i = start_pos - 1, start_pos + #idx_pattern - 2 do
                      table.insert(highlights, i)
                    end
                    log("HL_NUM: orig#" .. display_orig_idx .. " matched #" .. current_target_display_num)
                  end
                elseif current_target_type == "time" and current_target_time_str then
                  local display_time = display:match("%d+[smhdw]")
                  if display_time == current_target_time_str then
                    local pattern_start, pattern_end = display:find(display_time, 1, true)
                    if pattern_start and pattern_end then
                      for i = pattern_start - 1, pattern_end - 1 do
                        table.insert(highlights, i)
                      end
                      log("HL_TIME: orig#" .. display_orig_idx .. " matched " .. current_target_time_str)
                    end
                  end
                end
              end
            end
            if #current_text_queries > 0 then
              local name_start = display:find("%S+%.%S+")
              if name_start then
                local substr = display:sub(name_start)
                local all_hl_indices = {}
                for _, text_query in ipairs(current_text_queries) do
                  local fzy_hl = fzy_sorter:highlighter(text_query, substr)
                  if fzy_hl then
                    for _, char_idx in ipairs(fzy_hl) do
                      all_hl_indices[char_idx] = true
                    end
                  end
                end
                for char_idx, _ in pairs(all_hl_indices) do
                  table.insert(highlights, name_start + char_idx - 2)
                end
                if #highlights > 0 then
                  log("HL_TEXT: orig#" .. display_orig_idx .. " queries=" .. vim.inspect(current_text_queries) .. " matched " .. #highlights .. " chars in '" .. substr .. "'")
                end
              end
            end
            return highlights
          end,
        }
      end

      local picker = pickers.new({}, {
        prompt_title = "Smart Files (5 | 10m | config)",
        finder = make_finder(),
        sorter = smart_sorter(),
        attach_mappings = function(pb, map)
          actions.select_default:replace(function()
            local selection = action_state.get_selected_entry()
            if selection then
              log(">>> SELECTED: original_index #" .. selection.original_index .. " → " .. selection.path)
              actions.close(pb)
              vim.cmd("edit " .. vim.fn.fnameescape(selection.path))
            end
          end)
          return true
        end,
      })
      picker:find()
      vim.notify("Log: " .. log_file, vim.log.levels.INFO)
    end

    vim.api.nvim_create_user_command("SmartPicker", smart_file_picker, {})
    vim.keymap.set("n", "<leader>fs", smart_file_picker, {desc = "⚡ Smart file picker"})
  end,
}

