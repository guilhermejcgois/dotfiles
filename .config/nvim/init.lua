-- Bootstrap do lazy.nvim (plugin manager)
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Carrega opções, keymaps e plugins
require("opts")
require("keymaps")
require("lazy").setup(require("plugins"))

-- Configuração de LSP/CMP pós plugins
require("lsp")

