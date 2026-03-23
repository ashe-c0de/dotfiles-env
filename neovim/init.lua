-- ========================================================================== --
--                                基础设置 (Basic)                             --
-- ========================================================================== --

-- Leader 键必须最先定义
vim.g.mapleader = " "

-- 核心性能优化：解决 Windows 下 MkDocs 监听延迟和文件锁竞争
vim.opt.backupcopy = "yes"    -- 强制覆盖原文件，保持文件句柄不变，方便热重载
vim.opt.shada = "'100,<50,s10,h" -- 减少退出和保存时 shada 文件的写入开销
vim.opt.swapfile = false      -- 禁用交换文件（现代 SSD 不需要，且减少 IO）
vim.opt.timeoutlen = 500      -- 缩短 Leader 键等待时间

-- UI 设置
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true
vim.opt.clipboard = "unnamedplus" -- 使用系统剪贴板

-- ========================================================================== --
--                             快捷键映射 (Keymaps)                            --
-- ========================================================================== --

-- 安全保存：规避 'buftype' 错误
vim.keymap.set('n', '<leader>w', function()
    if vim.bo.buftype == "" and vim.bo.modifiable then
        vim.cmd("write")
    else
        vim.api.nvim_echo({{"当前窗口不可保存", "WarningMsg"}}, false, {})
    end
end, { desc = "Save File" })

-- ========================================================================== --
--                           插件管理 (Lazy.nvim)                             --
-- ========================================================================== --

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
  -- Treesitter (优化后的 1.x 配置)
  ----------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "rust", "go", "lua", "markdown", "markdown_inline", "toml" },
        highlight = {
          enable = true,
          -- 官方推荐的高性能大文件禁用方案
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then return true end
          end,
        },
      })
    end,
  },

  ----------------------
  -- Completion (补全)
  ----------------------
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path",
      "saadparwaiz1/cmp_luasnip", "L3MON4D3/LuaSnip",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" }, { name = "buffer" }, { name = "path" },
        }),
      })
    end,
  },

  ----------------------
  -- LSP & Languages
  ----------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local cap = require("cmp_nvim_lsp").default_capabilities()
      
      -- Go 语言服务器
      lspconfig.gopls.setup({ capabilities = cap })

      -- 快捷键
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
  },

  { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },

  ----------------------
  -- 格式化 (Conform.nvim) - 已改为手动触发
  ----------------------
  {
    "stevearc/conform.nvim",
    keys = {
      {
        "<leader>fl", -- 你之前的快捷键
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
      format_on_save = nil, -- 彻底禁用自动保存格式化，消除延迟
    },
  },

  ----------------------
  -- 文件树 (Neo-tree)
  ----------------------
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-tree/nvim-web-devicons", "MunifTanjim/nui.nvim" },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        window = { mappings = { ["<space>"] = "none" } }
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")
    end,
  },

  ----------------------
  -- 搜索 & 项目管理
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

  {
    "ahmedkhalf/project.nvim",
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "go.mod", "Cargo.toml" },
      })
      require("telescope").load_extension("projects")
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<CR>")
    end,
  },

  ----------------------
  -- UI & 主题
  ----------------------
  { "catppuccin/nvim", name = "catppuccin", priority = 1000, config = function() vim.cmd.colorscheme("catppuccin-mocha") end },
  
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim", "rcarriga/nvim-notify" },
    config = function()
      require("noice").setup({ lsp = { override = { ["cmp.entry.get_documentation"] = true } }, presets = { command_palette = true } })
    end,
  },

  {
    'nvim-lualine/lualine.nvim',
    config = function()
      require('lualine').setup({ options = { theme = 'auto' }, sections = { lualine_a = { 'mode' } } })
    end
  },

})
