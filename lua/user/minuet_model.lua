local M = {}

-- Edit only these three values when you switch local models.
M.model_name = "gemma-4-E4B-it-UD-Q8_K_XL"
M.model_path = vim.fn.expand("/home/progamers/Downloads/gemma-4-E4B-it-UD-Q8_K_XL.gguf")
M.llama_cli_bin = "/home/progamers/llama.cpp/build/bin/llama-server"

local host = "127.0.0.1"
local port = 8012

function M.llama_server_bin()
	return M.llama_cli_bin:gsub("llama%-cli$", "llama-server")
end

function M.completions_endpoint()
	return string.format("http://%s:%d/v1/completions", host, port)
end

function M.server_host()
	return host
end

function M.server_port()
	return port
end

return M
