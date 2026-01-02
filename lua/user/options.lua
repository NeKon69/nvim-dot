local opt = vim.opt
vim.o.sessionoptions = "buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,options,localoptions"
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
