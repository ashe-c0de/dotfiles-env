-- leader
vim.g.mapleader = " "

-- basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

-- 使用系统剪贴板
vim.opt.clipboard = "unnamedplus"

-- lazy.nvim install
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end

vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  ----------------------
  -- Treesitter
  ----------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "rust", "lua", "toml" },
        highlight = { enable = true },
        indent = { enable = true },
      })
    end,
  },

  ----------------------
  -- Completion
  ----------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip",
      "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")

      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),

        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        }),
      })
    end,
  },

  ----------------------
  -- Rust tools
  ----------------------
  {
    "mrcjkb/rustaceanvim",
    version = "^4",
    ft = { "rust" },
  },

  ----------------------
  -- crates.nvim
  ----------------------
  {
    "saecki/crates.nvim",
    ft = { "toml" },
    config = function()
      require("crates").setup()

      require("cmp").setup.buffer({
        sources = { { name = "crates" } }
      })
    end,
  },

  ----------------------
  -- Telescope
  ----------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim"
    },
    config = function()
      local builtin = require("telescope.builtin")

      vim.keymap.set("n","<leader>ff",builtin.find_files)
      vim.keymap.set("n","<leader>fg",builtin.live_grep)
      vim.keymap.set("n","<leader>fb",builtin.buffers)
      vim.keymap.set("n","<leader>fh",builtin.help_tags)
    end
  },

  ----------------------
  -- Neo-tree
  ----------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,

        window = {
          mappings = {
            ["<space>"] = "none",
            ["<cr>"] = "open",
            ["o"] = "open",
            ["s"] = "open_split",
            ["v"] = "open_vsplit",
            ["a"] = "add",
            ["d"] = "delete",
            ["r"] = "rename",
          }
        }
      })

      vim.keymap.set("n","<leader>e","<cmd>Neotree toggle<CR>")
    end
  },

})
