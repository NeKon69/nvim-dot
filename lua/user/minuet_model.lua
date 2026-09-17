local M = {}

-- ChatMock serves an OpenAI-compatible API locally.
M.primary_model = "gpt-5.4-mini"
M.fast_model = "gpt-5.2"
M.fallback_models = {
	"gpt-5.3-codex",
	"gpt-5.2",
	"gpt-5.1-codex-mini",
}

local host = "127.0.0.1"
local port = 8000
local command = "chatmock"
local cached_fast_mode_supported = nil

function M.chat_completions_endpoint()
	return string.format("http://%s:%d/v1/chat/completions", host, port)
end

function M.completions_endpoint()
	return M.chat_completions_endpoint()
end

function M.server_host()
	return host
end

function M.server_port()
	return port
end

function M.chatmock_command()
	return command
end

function M.model_candidates()
	local candidates = { M.primary_model }
	vim.list_extend(candidates, M.fallback_models)
	return candidates
end

function M.fast_mode_supported()
	if cached_fast_mode_supported ~= nil then
		return cached_fast_mode_supported
	end

	local res = vim.system({ command, "serve", "--help" }, { text = true }):wait()
	cached_fast_mode_supported = res.code == 0 and (res.stdout or ""):find("--fast-mode", 1, true) ~= nil
	return cached_fast_mode_supported
end

local function available_models()
	local res = vim.system({ "curl", "-sS", "--max-time", "1", string.format("http://%s:%d/v1/models", host, port) }, {
		text = true,
	}):wait()
	if res.code ~= 0 or res.stdout == "" then
		return nil
	end

	local ok, decoded = pcall(vim.json.decode, res.stdout)
	if not ok or type(decoded) ~= "table" or type(decoded.data) ~= "table" then
		return nil
	end

	local models = {}
	for _, item in ipairs(decoded.data) do
		if type(item) == "table" and type(item.id) == "string" then
			models[item.id] = true
		end
	end
	return models
end

function M.request_model()
	local models = available_models()
	if M.fast_mode_supported() and (not models or models[M.fast_model]) then
		return M.fast_model
	end

	if not models then
		return M.primary_model
	end

	for _, model in ipairs(M.model_candidates()) do
		if models[model] then
			return model
		end
	end

	return M.primary_model
end

function M.request_fast_mode(model)
	return model == M.fast_model and M.fast_mode_supported()
end

return M
