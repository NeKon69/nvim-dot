local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
vim.opt.cmdheight = 2
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
require("lazy").setup("plugins")
