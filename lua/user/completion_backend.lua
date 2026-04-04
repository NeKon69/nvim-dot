local M = {}

local state_file = vim.fn.stdpath("state") .. "/completion_backend.txt"
local valid_backends = {
	["local"] = true,
	codeium = true,
}

M.default_backend = "local"

local command_registered = false

local function read_backend()
	local ok, lines = pcall(vim.fn.readfile, state_file)
	if not ok or not lines or not lines[1] then
		return nil
	end

	local backend = vim.trim(lines[1])
	if valid_backends[backend] then
		return backend
	end

	return nil
end

function M.current()
	return read_backend() or M.default_backend
end

function M.set(backend)
	if not valid_backends[backend] then
		error("invalid completion backend: " .. tostring(backend))
	end

	local dir = vim.fn.fnamemodify(state_file, ":h")
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, "p")
	end

	vim.fn.writefile({ backend }, state_file)
	vim.notify("Completion backend set to " .. backend .. ". Restart Neovim to fully apply.")
	return backend
end

function M.setup_command()
	if command_registered then
		return
	end

	vim.api.nvim_create_user_command("CompletionBackend", function(opts)
		M.set(opts.args)
	end, {
		nargs = 1,
		complete = function()
			return { "local", "codeium" }
		end,
		desc = "Select completion backend",
	})

	command_registered = true
end

return M
