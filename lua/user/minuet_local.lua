local M = {}

local uv = vim.uv
local model_config = require("user.minuet_model")

local defaults = {
	server = {
		command = model_config.llama_server_bin(),
		model = model_config.model_path,
		host = model_config.server_host(),
		port = model_config.server_port(),
		ctx_size = 16384,
		n_gpu_layers = 99,
		threads = -1,
		flash_attn = "on",
		retries = 3,
		retry_backoff_ms = 1200,
		timeout_s = 25,
		stop_on_exit = true,
	},
}

local state = {
	config = vim.deepcopy(defaults),
	job = nil,
	pid = nil,
	watchdog = nil,
	starting = false,
	healthy = false,
	retries = 0,
	initialized = false,
	last_notify = {
		msg = nil,
		ts = 0,
	},
}

local function notify(msg, level)
	local now = uv.now()
	if state.last_notify.msg == msg and (now - state.last_notify.ts) < 1500 then
		return
	end
	state.last_notify.msg = msg
	state.last_notify.ts = now

	local function do_echo()
		local hl = "None"
		if (level or vim.log.levels.INFO) >= vim.log.levels.ERROR then
			hl = "ErrorMsg"
		elseif (level or vim.log.levels.INFO) >= vim.log.levels.WARN then
			hl = "WarningMsg"
		end
		pcall(vim.api.nvim_echo, { { "MinuetLocal: " .. msg, hl } }, true, {})
	end

	if vim.in_fast_event() then
		vim.schedule(do_echo)
	else
		do_echo()
	end
end

local function path_exists(path)
	return uv.fs_stat(path) ~= nil
end

local function kill(job)
	if not job then
		return
	end
	pcall(function()
		job:kill(15)
	end)
end

local function spawn_watchdog(llama_pid)
	if not llama_pid or llama_pid <= 0 then
		return
	end
	kill(state.watchdog)
	local nvim_pid = uv.os_getpid()
	local cmd = string.format(
		"while kill -0 %d >/dev/null 2>&1; do sleep 2; done; kill -TERM %d >/dev/null 2>&1",
		nvim_pid,
		llama_pid
	)
	state.watchdog = vim.system({ "sh", "-c", cmd }, { text = true }, function() end)
end

local function check_health(cb)
	local url = string.format("http://%s:%d/health", state.config.server.host, state.config.server.port)
	vim.system({ "curl", "-sS", "--max-time", "1", url }, { text = true }, function(res)
		cb(res.code == 0)
	end)
end

local function check_health_sync()
	local url = string.format("http://%s:%d/health", state.config.server.host, state.config.server.port)
	local res = vim.system({ "curl", "-sS", "--max-time", "1", url }, { text = true }):wait()
	return res.code == 0
end

local function set_unhealthy()
	state.starting = false
	state.healthy = false
end

local function wait_for_health_or_retry()
	local deadline = uv.now() + (state.config.server.timeout_s * 1000)
	local function poll()
		if not state.starting then
			return
		end
		check_health(function(ok)
			if ok then
				state.starting = false
				state.healthy = true
				notify("llama-server ready", vim.log.levels.INFO)
				return
			end
			if not state.starting then
				return
			end
			if uv.now() > deadline then
				set_unhealthy()
				state.retries = state.retries + 1
				if state.retries >= state.config.server.retries then
					notify("llama-server failed after retries", vim.log.levels.WARN)
					return
				end
				vim.defer_fn(function()
					M.start_server()
				end, state.config.server.retry_backoff_ms * state.retries)
				return
			end
			vim.defer_fn(poll, 300)
		end)
	end
	poll()
end

function M.start_server()
	if state.starting or state.healthy then
		return
	end

	local cfg = state.config.server
	if vim.fn.executable(cfg.command) ~= 1 then
		notify("command not found: " .. cfg.command, vim.log.levels.ERROR)
		return
	end
	if not path_exists(cfg.model) then
		notify("model not found: " .. cfg.model, vim.log.levels.ERROR)
		return
	end
	if check_health_sync() then
		state.healthy = true
		state.retries = 0
		return
	end

	state.starting = true
	local cmd = {
		cfg.command,
		"-m",
		cfg.model,
		"--host",
		cfg.host,
		"--port",
		tostring(cfg.port),
		"--ctx-size",
		tostring(cfg.ctx_size),
		"--n-gpu-layers",
		tostring(cfg.n_gpu_layers),
		"--threads",
		tostring(cfg.threads),
		"--flash-attn",
		cfg.flash_attn,
	}

	state.job = vim.system(cmd, { text = true }, function(res)
		set_unhealthy()
		if res.code ~= 0 then
			local err = vim.trim((res.stderr or ""):gsub("\n+", " "))
			if err ~= "" then
				notify("llama-server exited (" .. tostring(res.code) .. "): " .. err, vim.log.levels.WARN)
			else
				notify("llama-server exited (" .. tostring(res.code) .. ")", vim.log.levels.WARN)
			end
		end
	end)
	state.pid = state.job.pid
	spawn_watchdog(state.pid)
	wait_for_health_or_retry()
end

function M.stop_server()
	kill(state.watchdog)
	state.watchdog = nil
	kill(state.job)
	state.job = nil
	state.pid = nil
	state.starting = false
	state.healthy = false
end

function M.setup(opts)
	if state.initialized then
		return
	end
	state.config = vim.tbl_deep_extend("force", vim.deepcopy(defaults), opts or {})

	local group = vim.api.nvim_create_augroup("MinuetLocalServer", { clear = true })
	vim.api.nvim_create_autocmd("VimEnter", {
		group = group,
		callback = function()
			M.start_server()
		end,
	})
	vim.api.nvim_create_autocmd("VimLeavePre", {
		group = group,
		callback = function()
			if state.config.server.stop_on_exit then
				M.stop_server()
			end
		end,
	})

	vim.api.nvim_create_user_command("MinuetLocalStatus", function()
		local msg = string.format(
			"healthy=%s starting=%s pid=%s",
			tostring(state.healthy),
			tostring(state.starting),
			tostring(state.pid)
		)
		notify(msg)
	end, { desc = "Show local llama-server status" })

	if vim.v.vim_did_enter == 1 then
		vim.schedule(function()
			M.start_server()
		end)
	end

	state.initialized = true
end

return M
