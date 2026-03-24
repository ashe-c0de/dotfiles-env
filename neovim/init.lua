--[[
    这里是多行注释
    可以包含任意内容
    甚至可以跨越多行
]]

-- ==========================================================================
--                                基础设置 (Basic)
-- ==========================================================================

vim.g.mapleader = " "

-- Windows 性能优化
vim.opt.backupcopy = "yes"
vim.opt.shada = "'100,<50,s10,h"
vim.opt.swapfile = false
vim.opt.timeoutlen = 500

-- 禁用 Ctrl+LeftMouse 触发 Tag 跳转
vim.keymap.set("n", "<C-LeftMouse>", "<Nop>", { noremap = true, silent = true })

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

-- q关闭quickfix 窗口
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true })
  end,
})

-- ==========================================================================
--                             插件管理 (Lazy.nvim)
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
  -- LSP code-action
  ----------------------
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local cap = require("cmp_nvim_lsp").default_capabilities()

      lspconfig.gopls.setup({
        capabilities = cap,
        settings = {
          gopls = {
            completeUnimported = true,
            analyses = {
              unusedparams = true,
              shadow = true,
            },
            staticcheck = true,
            usePlaceholders = true,
            directoryFilters = { "-.git", "-.vscode", "-.idea", "-node_modules" },
            semanticTokens = true,
          },
        },
      })

      -- 快捷键设置
      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      -- 重命名快捷键
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
    end,
  },

  { "mrcjkb/rustaceanvim", version = "^4", ft = { "rust" } },

  ----------------------
  -- Format
  ----------------------
  {
    "stevearc/conform.nvim",
    -- 确保在打开文件时立即加载
    event = { "BufWritePre" }, 
    cmd = { "ConformInfo" },
    opts = {
      -- 1. 定义格式化器映射
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
        rust = { "rustfmt" },
        lua = { "stylua" },
      },
      -- 2. 设置格式化参数
      default_format_opts = {
        lsp_format = "fallback", -- 如果工具不可用，才使用 LSP
      },
    },
    -- 4. 快捷键映射
    keys = {
      {
        "<leader>fl",
        function()
          require("conform").format({ async = false, lsp_format = "fallback" })
        end,
        mode = "n",
        desc = "Format buffer (with GoImports)",
      },
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
    config = function ()
      require("neo-tree").setup({
        close_if_last_window = true,
          filesystem = {
            filtered_items = {
            visible = true,
            hide_dotfiles = false, 
            hide_gitignored = false,
            never_show = {},
          },
        },
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
  -- everforest theme
  ----------------------
  {
    "neanias/everforest-nvim",
    version = false,
    priority = 1000,
    config = function()
      require("everforest").setup({
        background = "soft", -- 关键：设置背景为柔和模式
        ui_contrast = "low", -- 降低对比度，更接近 GitHub Soft
        float_style = "bright", -- 浮窗稍微亮一点，方便区分
        on_highlights = function(hl, palette)
		  hl["@function"] = { fg = palette.blue, bold = true }
          hl["@function.call"] = { fg = palette.blue }
          hl["@method"] = { fg = palette.blue, bold = true }
        end,
      })
      vim.cmd("colorscheme everforest")
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

