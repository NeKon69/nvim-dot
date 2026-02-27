local M = {}

local state = {
	cache = nil,
	cache_path = vim.fn.stdpath("state") .. "/project-index.json",
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

local function default_cache()
	return {
		version = 1,
		projects = {},
		scanned = false,
	}
end

local function load_cache()
	if vim.fn.filereadable(state.cache_path) ~= 1 then
		return default_cache()
	end
	local ok, lines = pcall(vim.fn.readfile, state.cache_path)
	if not ok or type(lines) ~= "table" then
		return default_cache()
	end
	local raw = table.concat(lines, "\n")
	local ok_dec, decoded = pcall(vim.json.decode, raw)
	if not ok_dec or type(decoded) ~= "table" then
		return default_cache()
	end
	decoded.projects = type(decoded.projects) == "table" and decoded.projects or {}
	decoded.scanned = decoded.scanned == true
	decoded.version = 1
	return decoded
end

local function save_cache()
	vim.fn.mkdir(vim.fn.fnamemodify(state.cache_path, ":h"), "p")
	local payload = vim.json.encode(state.cache or default_cache())
	vim.fn.writefile({ payload }, state.cache_path)
end

local function marker_path(project_dir)
	return project_dir .. "/.nvim/project_marker"
end

local function ensure_marker(project_dir)
	local nvim_dir = project_dir .. "/.nvim"
	if vim.fn.isdirectory(nvim_dir) ~= 1 then
		return nil
	end
	local marker = marker_path(project_dir)
	if vim.fn.filereadable(marker) ~= 1 then
		local name = vim.fn.fnamemodify(project_dir, ":t")
		vim.fn.writefile({ name }, marker)
		return name
	end
	local ok, lines = pcall(vim.fn.readfile, marker)
	if not ok or type(lines) ~= "table" then
		return vim.fn.fnamemodify(project_dir, ":t")
	end
	local first = (lines[1] or ""):gsub("^%s+", ""):gsub("%s+$", "")
	if first == "" then
		first = vim.fn.fnamemodify(project_dir, ":t")
		vim.fn.writefile({ first }, marker)
	end
	return first
end

function M.register_project(path, opts)
	local project_dir = normalize_dir(path)
	if not project_dir then
		return false
	end
	if vim.fn.isdirectory(project_dir .. "/.nvim") ~= 1 then
		return false
	end
	state.cache = state.cache or load_cache()
	local name = ensure_marker(project_dir) or vim.fn.fnamemodify(project_dir, ":t")
	state.cache.projects[project_dir] = {
		name = name,
		updated_at = os.time(),
	}
	save_cache()
	if not (opts and opts.quiet) then
		vim.notify("Project indexed: " .. name, vim.log.levels.INFO)
	end
	return true
end

function M.get_projects()
	state.cache = state.cache or load_cache()
	local out = {}
	for path, meta in pairs(state.cache.projects) do
		if vim.fn.isdirectory(path) == 1 and vim.fn.isdirectory(path .. "/.nvim") == 1 then
			local name = ensure_marker(path) or (meta and meta.name) or vim.fn.fnamemodify(path, ":t")
			out[#out + 1] = { path = path, name = name }
		end
	end
	table.sort(out, function(a, b)
		return (a.name .. "\0" .. a.path) < (b.name .. "\0" .. b.path)
	end)
	return out
end

function M.get_extra_top_level_dirs()
	local roots = {
		vim.fn.expand("~/projects"),
		vim.fn.expand("~/CLionProjects"),
	}
	local out = {}
	local seen = {}
	for _, root in ipairs(roots) do
		local nr = normalize_dir(root)
		if nr and vim.fn.isdirectory(nr) == 1 then
			local fs = vim.uv.fs_scandir(nr)
			if fs then
				while true do
					local name, typ = vim.uv.fs_scandir_next(fs)
					if not name then
						break
					end
					if typ == "directory" then
						local full = normalize_dir(nr .. "/" .. name)
						if full and not seen[full] then
							seen[full] = true
							table.insert(out, full)
						end
					end
				end
			end
		end
	end
	table.sort(out)
	return out
end

local function first_full_scan()
	state.cache = state.cache or load_cache()
	if state.cache.scanned then
		return
	end
	local home = vim.uv.os_homedir() or vim.env.HOME
	if not home or home == "" then
		state.cache.scanned = true
		save_cache()
		return
	end
	local cmd = "find " .. vim.fn.shellescape(home) .. " -type d -name .nvim -print 2>/dev/null"
	local lines = vim.fn.systemlist(cmd)
	if type(lines) == "table" then
		for _, nvim_dir in ipairs(lines) do
			local project_dir = normalize_dir(vim.fn.fnamemodify(nvim_dir, ":h"))
			if project_dir then
				M.register_project(project_dir, { quiet = true })
			end
		end
	end
	state.cache.scanned = true
	save_cache()
end

function M.setup()
	state.cache = load_cache()
	first_full_scan()

	local cwd = normalize_dir(vim.fn.getcwd())
	if cwd then
		M.register_project(cwd, { quiet = true })
	end

	local grp = vim.api.nvim_create_augroup("ProjectIndex", { clear = true })
	vim.api.nvim_create_autocmd({ "VimEnter", "DirChanged" }, {
		group = grp,
		callback = function()
			local dir = normalize_dir(vim.fn.getcwd())
			if dir then
				M.register_project(dir, { quiet = true })
			end
		end,
	})
	vim.api.nvim_create_autocmd("BufWritePost", {
		group = grp,
		pattern = "project_marker",
		callback = function(args)
			local file = normalize_dir(vim.fn.fnamemodify(args.file, ":h:h"))
			if file then
				M.register_project(file, { quiet = true })
			end
		end,
	})
end

return M
