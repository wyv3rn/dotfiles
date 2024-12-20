-- Lazy plugin management
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
   vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable",   -- latest stable release
      lazypath,
   })
end
vim.opt.rtp:prepend(lazypath)

-- One key to lead them all (well, at least most of them), has to be loaded before lazy setup!
vim.g.mapleader = " "

require("lazy").setup("plugins")

-- Basic vim config
require("set")

-- Key mapping
require("map")

-- TODO git blame, current Plugin not working -> fugitive anyway?
