local project_root = require("user.project_root")

local M = {}

local function project_dir()
	return project_root.resolve() or vim.fn.getcwd()
end

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

local function config_path()
	return project_dir() .. "/.nvim/targets.json"
end

local function state_path()
	return project_dir() .. "/.nvim/targets.state.json"
end

local function default_config()
	return {
		version = 1,
		targets = {},
		metadata = {
			just = {
				available_targets = {},
				available_profiles = {},
				updated_at = os.time(),
			},
		},
	}
end

local function default_state()
	return {
		active_target = nil,
		active_profile = nil,
	}
end

local function read_json_file(path, fallback)
	if vim.fn.filereadable(path) ~= 1 then
		return vim.deepcopy(fallback)
	end
	local ok, lines = pcall(vim.fn.readfile, path)
	if not ok or type(lines) ~= "table" or #lines == 0 then
		return vim.deepcopy(fallback)
	end
	local ok_dec, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
	if not ok_dec or type(decoded) ~= "table" then
		return vim.deepcopy(fallback)
	end
	return decoded
end

local function write_json_file(path, data)
	local dir = vim.fn.fnamemodify(path, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end
	local ok, encoded = pcall(vim.json.encode, data)
	if not ok then
		return false
	end
	local tmp = path .. ".tmp"
	local wrote = pcall(vim.fn.writefile, { encoded }, tmp)
	if not wrote then
		return false
	end
	local renamed = os.rename(tmp, path)
	if not renamed then
		pcall(vim.fn.delete, tmp)
		return false
	end
	return true
end

local function ensure_tables(cfg)
	cfg.version = tonumber(cfg.version) or 1
	cfg.targets = type(cfg.targets) == "table" and cfg.targets or {}
	cfg.metadata = type(cfg.metadata) == "table" and cfg.metadata or {}
	cfg.metadata.just = type(cfg.metadata.just) == "table" and cfg.metadata.just or {}
	cfg.metadata.just.available_targets = type(cfg.metadata.just.available_targets) == "table"
			and cfg.metadata.just.available_targets
		or {}
	cfg.metadata.just.available_profiles = type(cfg.metadata.just.available_profiles) == "table"
			and cfg.metadata.just.available_profiles
		or {}
	for target_name, target in pairs(cfg.targets) do
		if type(target) == "table" then
			target.shared = type(target.shared) == "table" and target.shared or {}
			target.profiles = type(target.profiles) == "table" and target.profiles or {}
			target.actions = type(target.actions) == "table" and target.actions or {}
			if next(target.profiles) == nil then
				target.profiles.default = {}
			end
		else
			cfg.targets[target_name] = {
				language = "cpp",
				shared = {},
				profiles = { default = {} },
				actions = {},
			}
		end
	end
	return cfg
end

local function load_config_raw()
	return ensure_tables(read_json_file(config_path(), default_config()))
end

local function save_config(cfg)
	return write_json_file(config_path(), ensure_tables(cfg or default_config()))
end

local function load_state_raw()
	local st = read_json_file(state_path(), default_state())
	st.active_target = type(st.active_target) == "string" and st.active_target or nil
	st.active_profile = type(st.active_profile) == "string" and st.active_profile or nil
	return st
end

local function save_state(st)
	local out = {
		active_target = st and st.active_target or nil,
		active_profile = st and st.active_profile or nil,
	}
	return write_json_file(state_path(), out)
end

function M.ensure_files()
	local cfg = load_config_raw()
	save_config(cfg)
	local st = load_state_raw()
	save_state(st)
end

function M.load_config()
	return load_config_raw()
end

function M.config_file_path()
	return config_path()
end

function M.write_config(cfg)
	return save_config(cfg)
end

function M.list_targets()
	local cfg = load_config_raw()
	local out = {}
	for target_name, _ in pairs(cfg.targets) do
		table.insert(out, target_name)
	end
	table.sort(out)
	return out
end

function M.list_profiles(target_name)
	local cfg = load_config_raw()
	local target = cfg.targets[target_name]
	if type(target) ~= "table" or type(target.profiles) ~= "table" then
		return {}
	end
	local out = {}
	for profile_name, _ in pairs(target.profiles) do
		table.insert(out, profile_name)
	end
	table.sort(out)
	return out
end

function M.get_active()
	local st = load_state_raw()
	return st.active_target, st.active_profile
end

function M.set_active_target(target_name)
	local cfg = load_config_raw()
	local target = cfg.targets[target_name]
	if type(target) ~= "table" then
		return false, "Unknown target: " .. tostring(target_name)
	end
	local st = load_state_raw()
	st.active_target = target_name
	local profiles = M.list_profiles(target_name)
	if #profiles == 0 then
		return false, "Target has no profiles: " .. tostring(target_name)
	end
	if not st.active_profile or target.profiles[st.active_profile] == nil then
		st.active_profile = profiles[1]
	end
	save_state(st)
	return true
end

function M.set_active_profile(profile_name)
	local st = load_state_raw()
	if not st.active_target then
		return false, "No active target selected."
	end
	local cfg = load_config_raw()
	local target = cfg.targets[st.active_target]
	if type(target) ~= "table" then
		return false, "Unknown active target: " .. tostring(st.active_target)
	end
	if target.profiles[profile_name] == nil then
		return false, "Unknown profile '" .. tostring(profile_name) .. "' for target '" .. st.active_target .. "'."
	end
	st.active_profile = profile_name
	save_state(st)
	return true
end

function M.resolve_active()
	local cfg = load_config_raw()
	local st = load_state_raw()
	if not st.active_target or cfg.targets[st.active_target] == nil then
		return nil, nil, nil, "Selected target not found in .nvim/targets.json."
	end
	local target = cfg.targets[st.active_target]
	if not st.active_profile or target.profiles[st.active_profile] == nil then
		return nil, nil, nil, "Selected profile not found for target '" .. st.active_target .. "'."
	end
	return cfg, st.active_target, st.active_profile, nil
end

local function merge_tables(base, override)
	local out = vim.deepcopy(base or {})
	for k, v in pairs(override or {}) do
		if type(v) == "table" and type(out[k]) == "table" then
			out[k] = merge_tables(out[k], v)
		else
			out[k] = vim.deepcopy(v)
		end
	end
	return out
end

function M.get_effective(action_name)
	local cfg, target_name, profile_name, err = M.resolve_active()
	if err then
		return nil, err
	end
	local target = cfg.targets[target_name]
	local shared = target.shared or {}
	local profile = target.profiles[profile_name] or {}
	local action_cfg = (target.actions and target.actions[action_name]) or {}
	local effective = merge_tables(shared, profile)

	effective.target = target_name
	effective.profile = profile_name
	effective.language = target.language
	effective.action = action_name
	effective.action_cfg = action_cfg
	effective.rebuild_policy = action_cfg.rebuild_policy or target.rebuild_policy or "auto"
	effective.build_task = action_cfg.build_task or target.build_task or "build"
	effective.project_root = normalize_dir(project_dir()) or project_dir()
	if type(effective.language) ~= "string" or effective.language == "" then
		return nil, "Missing required field 'language' for target '" .. target_name .. "'."
	end

	if effective.args ~= nil and type(effective.args) ~= "table" then
		vim.notify("targets.json warning: 'args' should be an array for target " .. target_name, vim.log.levels.WARN)
		effective.args = {}
	end
	if effective.env ~= nil and type(effective.env) ~= "table" then
		vim.notify("targets.json warning: 'env' should be an object for target " .. target_name, vim.log.levels.WARN)
		effective.env = {}
	end
	if effective.debugger ~= nil and type(effective.debugger) ~= "table" then
		vim.notify("targets.json warning: 'debugger' should be an object for target " .. target_name, vim.log.levels.WARN)
		effective.debugger = {}
	end

	return effective, nil
end

function M.resolve_relative_path(path)
	if type(path) ~= "string" or path == "" then
		return nil
	end
	if path:sub(1, 1) == "/" or path:match("^[A-Za-z]:[\\/]") then
		return path
	end
	return (project_dir() .. "/" .. path):gsub("/+", "/")
end

function M.resolve_program(effective, probe_runner)
	if type(effective.program) == "string" and effective.program ~= "" then
		return M.resolve_relative_path(effective.program)
	end
	if type(effective.program_probe) == "table" and #effective.program_probe > 0 and type(probe_runner) == "function" then
		local program = probe_runner(effective.program_probe)
		if type(program) == "string" and program ~= "" then
			return M.resolve_relative_path(program)
		end
	end
	return nil
end

function M.resolve_args(effective)
	if type(effective.args) == "table" then
		return vim.deepcopy(effective.args)
	end
	return {}
end

function M.refresh_from_just(available_targets, available_profiles)
	local cfg = load_config_raw()
	cfg.metadata.just = cfg.metadata.just or {}
	cfg.metadata.just.available_targets = available_targets or {}
	cfg.metadata.just.available_profiles = available_profiles or {}
	cfg.metadata.just.updated_at = os.time()

	for _, target_name in ipairs(available_targets or {}) do
		if cfg.targets[target_name] == nil then
			cfg.targets[target_name] = {
				language = "cpp",
				shared = {},
				profiles = {},
				actions = {
					run = { executor = "overseer", task = "run" },
					debug = { executor = "dap", rebuild_policy = "auto", build_task = "build" },
				},
			}
		end
		local target = cfg.targets[target_name]
		target.profiles = target.profiles or {}
		for _, profile_name in ipairs(available_profiles or {}) do
			if target.profiles[profile_name] == nil then
				target.profiles[profile_name] = {}
			end
		end
		if next(target.profiles) == nil then
			target.profiles.default = {}
		end
	end

	save_config(cfg)
	M.ensure_files()
end

function M.upsert_target_profile(target_name, profile_name, payload)
	if type(target_name) ~= "string" or target_name == "" then
		return false, "Invalid target name."
	end
	if type(profile_name) ~= "string" or profile_name == "" then
		return false, "Invalid profile name."
	end
	local cfg = load_config_raw()
	cfg.targets[target_name] = cfg.targets[target_name] or {
		language = payload.language or "cpp",
		shared = {},
		profiles = {},
		actions = {
			run = { executor = "overseer", task = "run" },
			debug = { executor = "dap", rebuild_policy = "auto", build_task = "build" },
		},
	}
	local target = cfg.targets[target_name]
	target.shared = target.shared or {}
	target.profiles = target.profiles or {}
	target.actions = target.actions or {}
	target.actions.run = target.actions.run or { executor = "overseer", task = "run" }
	target.actions.debug = target.actions.debug or { executor = "dap", rebuild_policy = "auto", build_task = "build" }
	target.language = payload.language or target.language or "cpp"
	target.build_task = payload.build_task or target.build_task or "build"
	target.rebuild_policy = payload.rebuild_policy or target.rebuild_policy or "auto"

	target.profiles[profile_name] = target.profiles[profile_name] or {}
	local profile = target.profiles[profile_name]

	local scope = payload.scope == "profile" and "profile" or "shared"
	local dst = scope == "profile" and profile or target.shared

	if payload.program ~= nil then
		dst.program = payload.program
	end
	if payload.args ~= nil then
		dst.args = payload.args
	end
	if payload.cwd ~= nil then
		dst.cwd = payload.cwd
	end
	if payload.env ~= nil then
		dst.env = payload.env
	end
	if payload.debugger ~= nil then
		dst.debugger = payload.debugger
	end
	if payload.program_probe ~= nil then
		dst.program_probe = payload.program_probe
	end
	if target.language == "python" then
		profile.mode = payload.mode or profile.mode or "launch"
		if profile.mode == "pytest" then
			profile.pytest_target = payload.pytest_target or profile.pytest_target or "tests"
			profile.pytest_args = payload.pytest_args or profile.pytest_args or {}
		end
	end

	save_config(cfg)
	local ok_t = M.set_active_target(target_name)
	if ok_t then
		M.set_active_profile(profile_name)
	end
	return true
end

function M.delete_target(target_name)
	if type(target_name) ~= "string" or target_name == "" then
		return false, "Invalid target name."
	end
	local cfg = load_config_raw()
	if cfg.targets[target_name] == nil then
		return false, "Target not found: " .. target_name
	end
	cfg.targets[target_name] = nil
	save_config(cfg)

	local st = load_state_raw()
	if st.active_target == target_name then
		st.active_target = nil
		st.active_profile = nil
		local targets = M.list_targets()
		if #targets > 0 then
			st.active_target = targets[1]
			local profiles = M.list_profiles(st.active_target)
			st.active_profile = profiles[1] or nil
		end
		save_state(st)
	end
	return true
end

function M.delete_profile(target_name, profile_name)
	if type(target_name) ~= "string" or target_name == "" then
		return false, "Invalid target name."
	end
	if type(profile_name) ~= "string" or profile_name == "" then
		return false, "Invalid profile name."
	end
	local cfg = load_config_raw()
	local target = cfg.targets[target_name]
	if type(target) ~= "table" or type(target.profiles) ~= "table" then
		return false, "Target not found: " .. target_name
	end
	if target.profiles[profile_name] == nil then
		return false, "Profile not found: " .. profile_name
	end
	target.profiles[profile_name] = nil
	if next(target.profiles) == nil then
		target.profiles.default = {}
	end
	save_config(cfg)

	local st = load_state_raw()
	if st.active_target == target_name and st.active_profile == profile_name then
		local profiles = M.list_profiles(target_name)
		st.active_profile = profiles[1] or nil
		save_state(st)
	end
	return true
end

return M
