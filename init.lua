vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/site")
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

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
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

force_plugin_paths()
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

require("user.triforce_bridge")
require("user.options")
require("user.keymaps")
require("lazy").setup("plugins", {
	rocks = {
		enabled = false,
	},
})
require("user.project-setup").setup()
require("user.lspconfig")
require("user.history")
local clip = require("user.clipboard")
vim.keymap.set("n", "<leader>yy", clip.copy_as_tag, { desc = "Copy buffer with <file> tags" })
