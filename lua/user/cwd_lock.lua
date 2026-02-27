local M = {}
local project_index = require("user.project_index")

local state = {
	locked = nil,
	restoring = false,
}

local function normalize_dir(path)
	if not path or path == "" then
		return nil
	end
	local p = vim.fn.fnamemodify(path, ":p")
	local real = vim.uv.fs_realpath(p)
	p = real or p
	if vim.fn.isdirectory(p) == 0 then
		return nil
	end
	if p ~= "/" then
		p = p:gsub("/+$", "")
	end
	return p
end

local function set_locked_dir(path, opts)
	local target = normalize_dir(path)
	if not target then
		vim.notify("CwdLock: invalid directory: " .. tostring(path), vim.log.levels.ERROR)
		return false
	end

	state.locked = target
	vim.g.__nvim_locked_cwd = target

	if normalize_dir(vim.fn.getcwd()) ~= target then
		state.restoring = true
		vim.cmd("silent keepalt noautocmd cd " .. vim.fn.fnameescape(target))
		state.restoring = false
	end

	if not (opts and opts.quiet) then
		vim.notify("CwdLock: " .. target, vim.log.levels.INFO)
	end
	return true
end

local function enforce_lock()
	if state.restoring then
		return
	end
	local current = normalize_dir(vim.fn.getcwd())
	if not current then
		return
	end
	if not state.locked then
		state.locked = current
		vim.g.__nvim_locked_cwd = current
		return
	end
	if current == state.locked then
		return
	end
	state.restoring = true
	vim.schedule(function()
		vim.cmd("silent keepalt noautocmd cd " .. vim.fn.fnameescape(state.locked))
		state.restoring = false
		vim.notify("CwdLock blocked cwd change: " .. current, vim.log.levels.WARN)
	end)
end

function M.get()
	return state.locked
end

function M.set(path)
	local target = path
	if not target or target == "" then
		target = vim.fn.getcwd()
	end
	return set_locked_dir(target)
end

function M.setup()
	vim.opt.autochdir = false
	project_index.setup()

	local startup = vim.g.__nvim_startup_dir
	if type(startup) ~= "string" or startup == "" then
		startup = vim.fn.getcwd()
	end
	set_locked_dir(startup, { quiet = true })

	local grp = vim.api.nvim_create_augroup("CwdLock", { clear = true })
	vim.api.nvim_create_autocmd("DirChanged", {
		group = grp,
		callback = enforce_lock,
	})

	vim.api.nvim_create_user_command("CwdSet", function(opts)
		local path = opts.args ~= "" and opts.args or vim.fn.getcwd()
		set_locked_dir(path)
	end, {
		nargs = "?",
		complete = "dir",
		desc = "Set and lock Neovim cwd to a directory",
	})

	vim.api.nvim_create_user_command("CwdShow", function()
		vim.notify("CwdLock: " .. tostring(state.locked), vim.log.levels.INFO)
	end, {
		desc = "Show locked Neovim cwd",
	})

	vim.api.nvim_create_user_command("CwdPick", function()
		local ok = pcall(require, "telescope")
		if not ok then
			vim.notify("CwdPick requires telescope", vim.log.levels.ERROR)
			return
		end

		local pickers = require("telescope.pickers")
		local finders = require("telescope.finders")
		local conf = require("telescope.config").values
		local actions = require("telescope.actions")
		local action_state = require("telescope.actions.state")

		local function open_picker(default_text)
			local seen = {}
			local rows = {}
			local function add(path, kind, label)
				local dir = normalize_dir(path)
				if not dir or seen[dir] then
					return
				end
				seen[dir] = true
				rows[#rows + 1] = {
					path = dir,
					kind = kind,
					display = label .. " " .. dir,
					ordinal = kind .. "|" .. dir,
				}
			end

			add(state.locked, "0", "[LOCK]")
			add(vim.fn.getcwd(), "0", "[CWD]")
			add(vim.g.__nvim_startup_dir, "0", "[START]")

			for _, project in ipairs(project_index.get_projects()) do
				add(project.path, "1", "[P] " .. project.name)
			end
			for _, dir in ipairs(project_index.get_extra_top_level_dirs()) do
				add(dir, "2", "[D]")
			end
			for _, file in ipairs(vim.v.oldfiles or {}) do
				add(vim.fn.fnamemodify(file, ":h"), "3", "[R]")
			end

			table.sort(rows, function(a, b)
				return a.ordinal < b.ordinal
			end)

			pickers
				.new({}, {
					prompt_title = "Project/Directory Set",
					default_text = default_text or "",
					finder = finders.new_table({
						results = rows,
						entry_maker = function(item)
							return {
								value = item.path,
								display = item.display,
								ordinal = item.ordinal,
							}
						end,
					}),
					sorter = conf.generic_sorter({}),
					attach_mappings = function(prompt_bufnr)
						actions.select_default:replace(function()
							local selection = action_state.get_selected_entry()
							actions.close(prompt_bufnr)
							if selection and selection.value then
								set_locked_dir(selection.value)
								project_index.register_project(selection.value, { quiet = true })
							end
						end)
						return true
					end,
				})
				:find()
		end

		vim.ui.input({ prompt = "Path or search: " }, function(input)
			local value = type(input) == "string" and input:gsub("^%s+", ""):gsub("%s+$", "") or ""
			if value == "" then
				open_picker("")
				return
			end
			local expanded = normalize_dir(vim.fn.expand(value))
			if expanded then
				set_locked_dir(expanded)
				project_index.register_project(expanded, { quiet = true })
				return
			end
			open_picker(value)
		end)
	end, {
		desc = "Pick/set cwd (projects + directories)",
	})
end

return M
