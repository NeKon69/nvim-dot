local function force_plugin_paths()
	local lazy_root = vim.fn.stdpath("data") .. "/lazy"
	local handle = vim.loop.fs_scandir(lazy_root)
	if not handle then
		return
	end

	local extra_paths = {}
	while true do
		local name, type = vim.loop.fs_scandir_next(handle)
		if not name then
			break
		end
		if type == "directory" then
			local lua_path = lazy_root .. "/" .. name .. "/lua"
			if vim.loop.fs_stat(lua_path) then
				table.insert(extra_paths, lua_path .. "/?.lua")
				table.insert(extra_paths, lua_path .. "/?/init.lua")
			end
		end
	end

	if #extra_paths > 0 then
		package.path = package.path .. ";" .. table.concat(extra_paths, ";")
	end
end

force_plugin_paths()
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.cmdheight = 2
vim.opt.sessionoptions = {
	"buffers",
	"curdir",
	"tabpages",
	"winsize",
	"help",
	"globals",
	"skiprtp",
	"folds",
}
vim.opt.swapfile = false
vim.opt.shortmess:append("I")

if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable",
		lazypath,
	})
end

vim.opt.rtp:prepend(lazypath)

require("user.options")
require("user.keymaps")
require("lazy").setup("plugins", {
	rocks = {
		enabled = false,
	},
})
require("user.project-setup").setup()
local action_logger = require("user.key-logger")

vim.api.nvim_create_user_command("StartActionLogger", action_logger.start, {})
vim.api.nvim_create_user_command("StopActionLogger", action_logger.stop, {})
