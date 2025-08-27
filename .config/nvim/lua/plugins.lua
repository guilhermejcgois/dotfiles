return {
  -- Tema TokyoNight
  {
    "folke/tokyonight.nvim",
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "storm",           -- "storm", "night", "moon", "day"
        transparent = false,
        styles = { sidebars = "dark", floats = "dark" },
      })
      vim.cmd.colorscheme("tokyonight")
    end,
  },

  -- Statusline
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("lualine").setup({
        options = { theme = "tokyonight", globalstatus = true },
      })
    end,
  },

  -- Telescope (fuzzy finder)
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").setup({})
    end,
  },

  -- Treesitter (syntax/AST)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = {
          "lua","vim","vimdoc",
          "javascript","typescript","tsx",
          "json","yaml","toml","markdown","regex",
          "bash","python"
        },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  -- LSP management
  "williamboman/mason.nvim",
  "williamboman/mason-lspconfig.nvim",
  "neovim/nvim-lspconfig",

  -- Autocomplete
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
  },

  -- Ícones
  { "nvim-tree/nvim-web-devicons", lazy = true },

  -- Git signs (opcional, mas útil)
  {
    "lewis6991/gitsigns.nvim",
    config = function()
      require("gitsigns").setup({})
    end,
  },
}

