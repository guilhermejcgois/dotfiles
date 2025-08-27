-- Opções básicas
local opt = vim.opt
vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.number = true
opt.relativenumber = true
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"

opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true

opt.splitbelow = true
opt.splitright = true
opt.scrolloff = 4
opt.sidescrolloff = 8

opt.ignorecase = true
opt.smartcase = true

opt.updatetime = 250
opt.timeoutlen = 400

opt.clipboard = "unnamedplus"

