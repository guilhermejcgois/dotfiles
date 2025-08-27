local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Telescope
map("n", "<leader>ff", "<cmd>Telescope find_files<cr>", opts)
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", opts)
map("n", "<leader>fb", "<cmd>Telescope buffers<cr>", opts)
map("n", "<leader>fh", "<cmd>Telescope help_tags<cr>", opts)

-- Qualidade de vida
map("n", "<leader>e", "<cmd>Ex<cr>", opts)          -- netrw simples
map("n", "<leader>q", "<cmd>q<cr>", opts)
map("n", "<leader>w", "<cmd>w<cr>", opts)

-- Movimentação entre splits
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

