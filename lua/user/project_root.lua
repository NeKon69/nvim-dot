local M = {}

local marker_names = {
	".git",
	".nvim-root",
	"justfile",
	"package.json",
	"pyproject.toml",
	"Cargo.toml",
	"go.mod",
	"Makefile",
	"CMakeLists.txt",
}

local state = {
	startup_dir = nil,
	override_dir = nil,
}

local function trim_trailing_slash(path)
	if path == "/" then
		return path
	end
	if path:match("^[A-Za-z]:/$") then
		return path
	end
	return path:gsub("/+$", "")
end

local function normalize_dir(path)
	if not path or path == "" then
		return nil
	end

	local normalized = vim.fn.fnamemodify(path, ":p")
	local real = vim.uv.fs_realpath(normalized)
	normalized = real or normalized

	if vim.fn.isdirectory(normalized) == 0 then
		if vim.fn.filereadable(normalized) == 1 then
			normalized = vim.fn.fnamemodify(normalized, ":h")
		else
			return nil
		end
	end

	return trim_trailing_slash(vim.fn.fnamemodify(normalized, ":p"))
end

local function marker_root_for(start_dir, names)
	local marker = vim.fs.find(names, { upward = true, path = start_dir })[1]
	if not marker then
		return nil
	end
	return normalize_dir(vim.fn.fnamemodify(marker, ":h"))
end

local function detect_startup_dir()
	if type(vim.g.__nvim_startup_dir) == "string" and vim.g.__nvim_startup_dir ~= "" then
		local saved = normalize_dir(vim.g.__nvim_startup_dir)
		if saved then
			return saved
		end
	end

	local env_pwd = normalize_dir(vim.env.PWD)
	if env_pwd then
		return env_pwd
	end

	return normalize_dir(vim.fn.getcwd())
end

state.startup_dir = detect_startup_dir()
if state.startup_dir then
	vim.g.__nvim_startup_dir = state.startup_dir
end

function M.startup_dir()
	return state.startup_dir
end

function M.set_override(path)
	local dir = normalize_dir(path)
	if not dir then
		return false, "invalid directory"
	end
	state.override_dir = dir
	return true
end

function M.clear_override()
	state.override_dir = nil
end

function M.override_dir()
	return state.override_dir
end

function M.resolve()
	if state.override_dir then
		return state.override_dir
	end

	local anchor = state.startup_dir or normalize_dir(vim.fn.getcwd())
	if not anchor then
		return vim.fn.getcwd()
	end

	local git_root = marker_root_for(anchor, { ".git" })
	if git_root then
		return git_root
	end

	local marker_root = marker_root_for(anchor, marker_names)
	if marker_root then
		return marker_root
	end

	return anchor
end

return M
