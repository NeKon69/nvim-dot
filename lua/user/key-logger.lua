-- log_events.lua
local log_path = vim.fn.stdpath("cache") .. "/triforce_spy.log"

-- Очищаем файл перед стартом
local f = io.open(log_path, "w")
if f then
	f:write("--- ТРАССИРОВКА СОБЫТИЙ ЗАПУЩЕНА: " .. os.date() .. " ---\n")
	f:close()
end

local function log_to_file(event_type, match)
	local msg = string.format("[%s] %s | Match: %s\n", os.date("%H:%M:%S"), event_type, tostring(match))
	local f = io.open(log_path, "a")
	if f then
		f:write(msg)
		f:close()
	end
end

-- Слушаем все основные типы событий, которые нам интересны
local events = { "User", "FileType", "TermOpen", "BufEnter" }

vim.api.nvim_create_autocmd(events, {
	callback = function(args)
		log_to_file(args.event, args.match)
	end,
})

print("Шпион запущен! Лог здесь: " .. log_path)
print("Сделай действия (Telescope, Harpoon, Overseer) и скинь содержимое лога.")
