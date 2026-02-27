local M = {}
local project_root = require("user.project_root")

local session_prompted = {}
local state = {
	active_root = nil,
	active_venv = nil,
	mapped_root = nil,
	mappings_enabled = false,
}

local function get_root()
	return project_root.resolve()
end

local function nvim_dir(root)
	return root .. "/.nvim"
end

local function metadata_path(root)
	return nvim_dir(root) .. "/python-env.json"
end

local function venv_dir(root)
	return nvim_dir(root) .. "/venv"
end

local function venv_python(root)
	return venv_dir(root) .. "/bin/python"
end

local function ensure_nvim_dir(root)
	if vim.fn.isdirectory(nvim_dir(root)) == 0 then
		vim.fn.mkdir(nvim_dir(root), "p")
	end
end

local function read_metadata(root)
	local file = metadata_path(root)
	if vim.fn.filereadable(file) ~= 1 then
		return nil
	end
	local ok, lines = pcall(vim.fn.readfile, file)
	if not ok or not lines or #lines == 0 then
		return nil
	end
	local joined = table.concat(lines, "\n")
	local ok_json, data = pcall(vim.json.decode, joined)
	if not ok_json or type(data) ~= "table" then
		return nil
	end
	return data
end

local function write_metadata(root, accepted)
	ensure_nvim_dir(root)
	local payload = {
		accepted = accepted,
		updated_at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
	}
	local ok, encoded = pcall(vim.json.encode, payload)
	if not ok then
		return false
	end
	local tmp = metadata_path(root) .. ".tmp"
	local wrote = pcall(vim.fn.writefile, { encoded }, tmp)
	if not wrote then
		return false
	end
	local renamed = os.rename(tmp, metadata_path(root))
	if not renamed then
		pcall(vim.fn.delete, tmp)
		return false
	end
	return true
end

local function is_python_project(root)
	if #vim.fn.globpath(root, "*.py", false, true) > 0 then
		return true
	end
	local py_markers = { "pyproject.toml", "setup.py", "requirements.txt" }
	for _, marker in ipairs(py_markers) do
		if vim.fn.filereadable(root .. "/" .. marker) == 1 then
			return true
		end
	end
	return false
end

local function has_python_files_in_root(root)
	return #vim.fn.globpath(root, "*.py", false, true) > 0
end

local mapping_defs = {
	{ lhs = "<leader>pa", rhs = "<cmd>PyVenvActivate<CR>", desc = "Python: Activate .nvim/venv" },
	{ lhs = "<leader>pv", rhs = "<cmd>PyVenvCreate<CR>", desc = "Python: Create .nvim/venv" },
}

local function set_mappings(enabled, root)
	if enabled and state.mappings_enabled and state.mapped_root == root then
		return
	end
	if not enabled and not state.mappings_enabled then
		return
	end

	if enabled then
		for _, mapdef in ipairs(mapping_defs) do
			vim.keymap.set("n", mapdef.lhs, mapdef.rhs, { desc = mapdef.desc, silent = true })
		end
		state.mappings_enabled = true
		state.mapped_root = root
	else
		for _, mapdef in ipairs(mapping_defs) do
			pcall(vim.keymap.del, "n", mapdef.lhs)
		end
		state.mappings_enabled = false
		state.mapped_root = nil
	end
end

local function build_path_with_venv(root)
	local venv_bin = venv_dir(root) .. "/bin"
	local current = vim.env.PATH or ""
	local parts = vim.split(current, ":", { plain = true, trimempty = true })
	local filtered = {}
	for _, part in ipairs(parts) do
		if part ~= venv_bin then
			table.insert(filtered, part)
		end
	end
	table.insert(filtered, 1, venv_bin)
	return table.concat(filtered, ":")
end

local function refresh_python_lsp()
	for _, client in ipairs(vim.lsp.get_clients()) do
		if client.name == "basedpyright" then
			client:stop(true)
		end
	end
	local server = vim.g.python_lsp_server or "basedpyright"
	vim.schedule(function()
		pcall(vim.lsp.enable, server)
	end)
end

local function activate(root, notify)
	if vim.fn.executable(venv_python(root)) ~= 1 then
		return false
	end

	local venv = venv_dir(root)
	if state.active_root == root and state.active_venv == venv and vim.env.VIRTUAL_ENV == venv then
		return true
	end

	vim.env.VIRTUAL_ENV = venv
	vim.env.PATH = build_path_with_venv(root)
	state.active_root = root
	state.active_venv = venv
	refresh_python_lsp()

	if notify then
		vim.notify("Activated Python venv: " .. venv, vim.log.levels.INFO)
	end
	return true
end

local function create_venv(root, notify)
	ensure_nvim_dir(root)
	if vim.fn.executable(venv_python(root)) == 1 then
		if notify then
			vim.notify("Python venv already exists: " .. venv_dir(root), vim.log.levels.INFO)
		end
		return true
	end

	local result = vim.system({ "python3", "-m", "venv", ".nvim/venv" }, { cwd = root }):wait()
	if result.code ~= 0 then
		vim.notify("Failed to create .nvim/venv: " .. (result.stderr or "unknown error"), vim.log.levels.ERROR)
		return false
	end

	if notify then
		vim.notify("Created Python venv: " .. venv_dir(root), vim.log.levels.INFO)
	end
	return true
end

local function get_shell_activate_cmd(venv)
	if not venv or venv == "" then
		return nil
	end

	local fish_activate = venv .. "/bin/activate.fish"
	if vim.fn.filereadable(fish_activate) == 1 then
		return "source " .. vim.fn.shellescape(fish_activate)
	end

	local sh_activate = venv .. "/bin/activate"
	if vim.fn.filereadable(sh_activate) == 1 then
		return "source " .. vim.fn.shellescape(sh_activate)
	end

	return nil
end

local function terminal_argv(bufnr)
	local job_id = vim.b[bufnr].terminal_job_id
	if not job_id then
		return nil
	end
	local ok, info = pcall(vim.api.nvim_get_chan_info, job_id)
	if not ok or type(info) ~= "table" then
		return nil
	end
	return info.argv, job_id
end

local function should_activate_in_terminal(bufnr)
	local argv = terminal_argv(bufnr)
	if not argv or type(argv) ~= "table" or #argv == 0 then
		return false
	end

	local shell = vim.fn.fnamemodify(argv[1] or "", ":t")
	local known_shells = {
		fish = true,
		bash = true,
		zsh = true,
		sh = true,
	}
	return known_shells[shell] == true
end

local function prompt_create(root)
	session_prompted[root] = true
	vim.ui.select({ "Yes", "No" }, {
		prompt = "Create project Python env at .nvim/venv?",
	}, function(choice)
		if choice == "Yes" then
			write_metadata(root, true)
			if create_venv(root, true) then
				activate(root, true)
			end
		else
			write_metadata(root, false)
			vim.notify("Skipped .nvim/venv for this project. Use :PyVenvCreate", vim.log.levels.INFO)
		end
	end)
end

local function handle_project()
	local root = get_root()
	if root == "" then
		set_mappings(false)
		return
	end

	set_mappings(has_python_files_in_root(root), root)
	if not is_python_project(root) then
		return
	end

	if vim.fn.executable(venv_python(root)) == 1 then
		activate(root, false)
		return
	end

	local metadata = read_metadata(root)
	if metadata and metadata.accepted == true then
		if create_venv(root, false) then
			activate(root, false)
		end
		return
	end
	if metadata and metadata.accepted == false then
		return
	end

	if not session_prompted[root] then
		prompt_create(root)
	end
end

function M.setup()
	vim.api.nvim_create_user_command("PyVenvCreate", function()
		local root = get_root()
		if create_venv(root, true) then
			write_metadata(root, true)
			activate(root, true)
		end
	end, {})

	vim.api.nvim_create_user_command("PyVenvActivate", function()
		local root = get_root()
		if not activate(root, true) then
			vim.notify("No .nvim/venv found. Run :PyVenvCreate", vim.log.levels.WARN)
		end
	end, {})

	vim.api.nvim_create_user_command("PyVenvStatus", function()
		local root = get_root()
		local metadata = read_metadata(root)
		local status = vim.fn.executable(venv_python(root)) == 1 and "present" or "missing"
		local decision = metadata and tostring(metadata.accepted) or "unset"
		vim.notify(string.format("root=%s venv=%s decision=%s", root, status, decision), vim.log.levels.INFO)
	end, {})

	local grp = vim.api.nvim_create_augroup("ProjectPythonVenv", { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		group = grp,
		callback = function()
			vim.schedule(handle_project)
		end,
	})

	vim.api.nvim_create_autocmd("TermOpen", {
		group = grp,
		callback = function(args)
			if not should_activate_in_terminal(args.buf) then
				return
			end

			local _, job_id = terminal_argv(args.buf)
			if not job_id then
				return
			end

			local activate_cmd = get_shell_activate_cmd(vim.env.VIRTUAL_ENV)
			if not activate_cmd then
				return
			end

			vim.schedule(function()
				pcall(vim.fn.chansend, job_id, activate_cmd .. "\n")
			end)
		end,
	})
end

return M
