-- ==========================================================================
--                                基础设置 (Basic)
-- ==========================================================================

vim.g.mapleader = " "

-- Windows 性能优化
vim.opt.backupcopy = "yes"
vim.opt.shada = "'100,<50,s10,h"
vim.opt.swapfile = false
vim.opt.timeoutlen = 500

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus"

-- ==========================================================================
--                             快捷键映射 (Keymaps)
-- ==========================================================================

vim.keymap.set('n', '<leader>w', function()
    if vim.bo.buftype == "" and vim.bo.modifiable then
        vim.cmd("write")
    else
        vim.api.nvim_echo({{"当前窗口不可保存", "WarningMsg"}}, false, {})
    end
end, { desc = "Save File" })

-- ==========================================================================
--                           插件管理 (Lazy.nvim)
-- ==========================================================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
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
        ensure_installed = { "rust", "go", "lua", "markdown", "markdown_inline", "toml" },
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
          disable = function(_, buf)
            local max_filesize = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
        },
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
  -- LSP
  ----------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local cap = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.gopls.setup({ capabilities = cap })

      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
  },

  { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },

  ----------------------
  -- Format
  ----------------------
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>fl",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "n",
        desc = "Format buffer",
      },
    },
    opts = {
      formatters_by_ft = {
        lua = { "stylua" },
        rust = { "rustfmt" },
        go = { "goimports", "gofmt" },
      },
      format_on_save = nil,
    },
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
      "MunifTanjim/nui.nvim"
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { mappings = { ["<space>"] = "none" } }
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")
    end,
  },

  ----------------------
  -- Telescope
  ----------------------
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    end
  },

  ----------------------
  -- Project
  ----------------------
  {
    "ahmedkhalf/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "go.mod", "Cargo.toml" },
      })
  
      -- 确保 telescope 已加载再调用
      pcall(function()
        require("telescope").load_extension("projects")
      end)
  
      vim.keymap.set("n", "<leader>fp", function()
        require("telescope").extensions.projects.projects()
      end, { desc = "Projects" })
    end,
  },

  ----------------------
  -- 🌙 GitHub Soft Dark Theme
  ----------------------
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    priority = 1000,
    config = function()
      require("github-theme").setup({
        options = {
          theme_style = "dark_dimmed",

          styles = {
            comments = "italic",
            keywords = "bold",
          },

          darken = {
            floats = true,
            sidebars = {
              enable = true,
              list = {},
            },
          },

          hide_end_of_buffer = true,
          dim_inactive = false,
          module_default = true,
        },
      })

      vim.cmd("colorscheme github_dark_dimmed")
    end,
  },

  ----------------------
  -- Noice
  ----------------------
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify"
    },
    config = function()
      require("noice").setup({
        lsp = {
          override = {
            ["cmp.entry.get_documentation"] = true
          }
        },
        presets = {
          command_palette = true
        }
      })
    end,
  },

  ----------------------
  -- Lualine
  ----------------------
  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require('lualine').setup({
        options = {
          theme = "auto",
          globalstatus = true,
        },
        sections = {
          lualine_a = { 'mode' }
        }
      })
    end
  },

})

-- ==========================================================================
-- 额外 UI 优化（护眼关键）
-- ==========================================================================

-- 去掉背景（如果你终端透明可以保留）
-- vim.cmd("highlight Normal guibg=NONE ctermbg=NONE")
