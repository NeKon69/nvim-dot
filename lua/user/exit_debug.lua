local M = {}

local state = {
	initialized = false,
	start_ns = vim.uv.hrtime(),
	last_ns = nil,
	log_path = "/tmp/nvim-exit-debug.log",
	wrapped = {},
	in_exit = false,
}

local function now_ns()
	return vim.uv.hrtime()
end

local function ms_since(ns)
	return string.format("%.1f", (now_ns() - ns) / 1e6)
end

local function short(path)
	if not path or path == "" then
		return ""
	end
	if #path <= 160 then
		return path
	end
	return path:sub(1, 157) .. "..."
end

local function snapshot()
	local terms = {}
	for _, buf in ipairs(vim.api.nvim_list_bufs()) do
		if vim.api.nvim_buf_is_valid(buf) and vim.bo[buf].buftype == "terminal" then
			terms[#terms + 1] = short(vim.api.nvim_buf_get_name(buf))
		end
	end

	return string.format(
		"pid=%s cwd=%s mode=%s wins=%d bufs=%d terms=%d cur=%s",
		tostring(vim.fn.getpid()),
		short(vim.fn.getcwd()),
		tostring(vim.fn.mode()),
		#vim.api.nvim_list_wins(),
		#vim.api.nvim_list_bufs(),
		#terms,
		short(vim.api.nvim_buf_get_name(0))
	)
end

local function hook_summary(event)
	local ok, hooks = pcall(vim.api.nvim_get_autocmds, { event = event })
	if not ok then
		return event .. " hooks=<error>"
	end

	local parts = {}
	for _, hook in ipairs(hooks) do
		local label = hook.group_name or "<nogroup>"
		if hook.desc and hook.desc ~= "" then
			label = label .. ":" .. hook.desc
		elseif hook.command and hook.command ~= "" then
			label = label .. ":cmd"
		end
		parts[#parts + 1] = label
	end
	table.sort(parts)
	return event .. " hooks=" .. table.concat(parts, ", ")
end

local function dap_summary()
	local ok, dap = pcall(require, "dap")
	if not ok then
		return "dap unavailable"
	end
	local current = dap.session() ~= nil
	local sessions = 0
	local ok_sessions, all = pcall(dap.sessions)
	if ok_sessions and type(all) == "table" then
		sessions = vim.tbl_count(all)
	end
	return string.format("dap current=%s sessions=%d", tostring(current), sessions)
end

local function log_line(message)
	local f = io.open(state.log_path, "a")
	if not f then
		return
	end

	local last_delta = state.last_ns and string.format("+%sms", ms_since(state.last_ns)) or "+0.0ms"
	local start_delta = string.format("t=%sms", ms_since(state.start_ns))
	f:write(string.format("[%s] [%s] [%s] %s\n", os.date("%Y-%m-%d %H:%M:%S"), start_delta, last_delta, message))
	f:close()
	state.last_ns = now_ns()
end

local function wrap_loaded_function(modname, fnname, label)
	local mod = package.loaded[modname]
	if type(mod) ~= "table" or type(mod[fnname]) ~= "function" then
		return
	end

	local key = modname .. "." .. fnname
	if state.wrapped[key] then
		return
	end

	state.wrapped[key] = true
	local original = mod[fnname]
	mod[fnname] = function(...)
		local started = now_ns()
		log_line(label .. " start " .. snapshot())
		local result = { xpcall(original, debug.traceback, ...) }
		local ok = table.remove(result, 1)
		if ok then
			log_line(label .. " end elapsed=" .. string.format("%.1fms", (now_ns() - started) / 1e6))
			return unpack(result)
		end
		log_line(
			label
				.. " error elapsed="
				.. string.format("%.1fms", (now_ns() - started) / 1e6)
				.. " err="
				.. tostring(result[1])
		)
		error(result[1])
	end
	log_line("wrapped " .. key)
end

local function wrap_global_function(tbl, key, label)
	local fn = tbl[key]
	if type(fn) ~= "function" or state.wrapped[label] then
		return
	end

	state.wrapped[label] = true
	tbl[key] = function(...)
		if not state.in_exit then
			return fn(...)
		end
		local started = now_ns()
		log_line(label .. " start")
		local result = { xpcall(fn, debug.traceback, ...) }
		local ok = table.remove(result, 1)
		if ok then
			log_line(label .. " end elapsed=" .. string.format("%.1fms", (now_ns() - started) / 1e6))
			return unpack(result)
		end
		log_line(
			label
				.. " error elapsed="
				.. string.format("%.1fms", (now_ns() - started) / 1e6)
				.. " err="
				.. tostring(result[1])
		)
		error(result[1])
	end
	log_line("wrapped " .. label)
end

local function install_wrappers()
	wrap_loaded_function("user.minuet_local", "start_server", "minuet_local.start_server")
	wrap_loaded_function("user.minuet_local", "stop_server", "minuet_local.stop_server")
	wrap_loaded_function("persistence", "save", "persistence.save")
	wrap_loaded_function("harpoon", "sync", "harpoon.sync")
	wrap_loaded_function("gitsigns.attach", "detach_all", "gitsigns.detach_all")
	wrap_loaded_function("gitsigns.attach", "detach", "gitsigns.detach")
	wrap_loaded_function("snacks.image.placement", "clean", "snacks.image.clean")
	wrap_loaded_function("taka-time.core", "on_exit", "takatime.on_exit")
	wrap_loaded_function("triforce.tracker", "shutdown", "triforce.shutdown")
	wrap_loaded_function("noice", "disable", "noice.disable")
	wrap_global_function(vim.fn, "system", "vim.fn.system")
	wrap_global_function(vim, "wait", "vim.wait")
end

function M.setup(opts)
	if state.initialized then
		return
	end
	state.initialized = true
	state.log_path = (opts and opts.log_path) or state.log_path

	log_line("session start " .. snapshot())
	install_wrappers()

	local group = vim.api.nvim_create_augroup("ExitDebug", { clear = true })

	vim.api.nvim_create_autocmd({ "VimEnter", "User" }, {
		group = group,
		pattern = { "*", "VeryLazy", "LazyDone" },
		callback = function(ev)
			install_wrappers()
			log_line(ev.event .. (ev.match ~= "" and (":" .. ev.match) or "") .. " " .. snapshot())
		end,
	})

	vim.api.nvim_create_autocmd({ "QuitPre", "ExitPre", "VimLeavePre", "VimLeave" }, {
		group = group,
		callback = function(ev)
			install_wrappers()
			if ev.event == "QuitPre" then
				state.in_exit = true
				log_line(hook_summary("QuitPre"))
				log_line(hook_summary("ExitPre"))
				log_line(hook_summary("VimLeavePre"))
				log_line(dap_summary())
			end
			log_line(ev.event .. " " .. snapshot())
		end,
	})

	vim.api.nvim_create_user_command("ExitDebugOpen", function()
		vim.cmd("tabnew " .. vim.fn.fnameescape(state.log_path))
	end, { desc = "Open exit debug log" })

	vim.api.nvim_create_user_command("ExitDebugClear", function()
		local f = io.open(state.log_path, "w")
		if f then
			f:close()
		end
		log_line("log cleared " .. snapshot())
	end, { desc = "Clear exit debug log" })
end

return M
