local opt = vim.opt
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,options,localoptions"

if (vim.env.WAYLAND_DISPLAY or "") == "" and (vim.env.XDG_RUNTIME_DIR or "") ~= "" then
	local wayland_sockets = vim.fn.glob(vim.env.XDG_RUNTIME_DIR .. "/wayland-*", false, true)
	local socket_names = {}
	for _, socket in ipairs(wayland_sockets) do
		if not socket:match("%.lock$") then
			table.insert(socket_names, vim.fn.fnamemodify(socket, ":t"))
		end
	end
	if #socket_names > 0 then
		table.sort(socket_names)
		vim.env.WAYLAND_DISPLAY = socket_names[#socket_names]
	end
end

local wl_copy = vim.fn.exepath("wl-copy")
local wl_paste = vim.fn.exepath("wl-paste")

if wl_copy ~= "" and wl_paste ~= "" and (vim.env.WAYLAND_DISPLAY or "") ~= "" then
	vim.g.clipboard = {
		name = "wl-clipboard",
		copy = {
			["+"] = { wl_copy, "--type", "text/plain" },
			["*"] = { wl_copy, "--primary", "--type", "text/plain" },
		},
		paste = {
			["+"] = { wl_paste, "--no-newline" },
			["*"] = { wl_paste, "--no-newline", "--primary" },
		},
		cache_enabled = 1,
	}
end

opt.clipboard = "unnamedplus"
opt.scrolloff = 8
opt.sidescrolloff = 8

opt.number = true
opt.relativenumber = true

opt.incsearch = true
opt.hlsearch = true
opt.inccommand = "split"
opt.ignorecase = true
opt.smartcase = true

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserIndentExpr", { clear = true }),
	callback = function(args)
		vim.bo[args.buf].indentexpr = ""
		vim.bo[args.buf].cindent = false
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("UserLlvmIndent", { clear = true }),
	pattern = { "c", "cpp", "cuda" },
	callback = function(args)
		local filename = vim.api.nvim_buf_get_name(args.buf)
		if not filename:match("/llvm%-project/") then
			return
		end

		vim.bo[args.buf].tabstop = 2
		vim.bo[args.buf].softtabstop = 2
		vim.bo[args.buf].shiftwidth = 2
	end,
})

opt.termguicolors = true
opt.signcolumn = "yes"
opt.wrap = false
opt.cursorline = true

opt.updatetime = 500
opt.undofile = true

opt.cmdheight = 2
opt.shortmess:append("I")
opt.shortmess:append("c")
opt.shortmess:append("S")

vim.g.mapleader = " "
vim.g.maplocalleader = " "
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1
vim.opt.shortmess:append("IFc")

vim.api.nvim_create_augroup("FileExplorer", { clear = true })

vim.opt.autochdir = false
