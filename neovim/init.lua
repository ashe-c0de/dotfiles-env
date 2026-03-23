-- leader
vim.g.mapleader = " "

-- basic options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

-- 使用系统剪贴板
vim.opt.clipboard = "unnamedplus"

-- 文件搜索
vim.keymap.set("n", "<leader>f", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })

-- 全局搜索
vim.keymap.set("n", "<leader>g", function()
  require("telescope.builtin").live_grep()
end)

-- 文件树
vim.keymap.set("n", "<leader>e", "<cmd>NvimTreeToggle<CR>")

-- 保存
vim.keymap.set("n", "<leader>w", "<cmd>w<CR>")

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
  -- Treesitter (适配 2026 最新 v1.x 版本)
  ----------------------
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    lazy = false,
  
    config = function()
      -- 基础 setup（新版本其实可选）
      require("nvim-treesitter").setup({
        install_dir = vim.fn.stdpath("data") .. "/site",
      })
  
      -- 安装语言
      require("nvim-treesitter").install({
        "rust",
        "lua",
        "toml",
        "markdown",
        "markdown_inline",
        "go",
      })
  
      -- Treesitter + 大文件保护
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "lua", "go", "rust", "markdown", "toml" },
        callback = function()
          -- 文件路径
          local buf = vim.api.nvim_get_current_buf()
          local filename = vim.api.nvim_buf_get_name(buf)
  
          -- 获取文件大小
          local ok, stats = pcall(vim.loop.fs_stat, filename)
  
          -- 100KB 阈值（你可以改）
          local max_filesize = 100 * 1024
  
          if ok and stats and stats.size > max_filesize then
            return -- 大文件不启用 treesitter
          end
  
          -- 启用 Treesitter
          pcall(vim.treesitter.start)
        end,
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

  ----------------------
  -- 配色方案 (Colorscheme)
  ----------------------
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000, -- 确保主题先加载
    config = function()
      vim.cmd.colorscheme("catppuccin-mocha") -- 推荐 mocha 暗色调
    end,
  },
  
  ----------------------
  -- UI增强
  ----------------------
  {
  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify", -- 漂亮的右上角通知弹窗
  },
  config = function()
    require("noice").setup({
      lsp = {
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.styled_parts"] = true,
          ["cmp.entry.get_documentation"] = true,
        },
      },
      presets = {
        bottom_search = true, -- 搜索栏在底部
        command_palette = true, -- 命令输入框在中间（像 Spotlight）
        long_message_to_split = true,
      },
    })
  end,
},

----------------------
-- 语法自动格式化
----------------------
{
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      lua = { "stylua" },
      rust = { "rustfmt" },
    },
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
  },
},

----------------------
-- 工作区 / 项目管理
----------------------
{
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      detection_methods = { "pattern" },

      patterns = {
        ".git",
        "go.mod",
        "Cargo.toml",
        "pom.xml",
      },
	  -- 不符合patterns的直接不被视为project dir
      manual_mode = false,
    })

    -- Telescope 集成
    require("telescope").load_extension("projects")

    -- 最近项目
    vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<CR>", { desc = "Projects" })
  end,
},

----------------------
-- LSP自动导包
----------------------
{
  "neovim/nvim-lspconfig",
  config = function()
    local lspconfig = require("lspconfig")
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    lspconfig.gopls.setup({
      capabilities = capabilities,
    })

    -- 跳转到定义
    vim.keymap.set("n", "gd", vim.lsp.buf.definition)
	-- 查找所有引用
    vim.keymap.set("n", "gr", vim.lsp.buf.references)
	-- 查看文档（像 IDE 悬浮提示）
    vim.keymap.set("n", "K", vim.lsp.buf.hover)

    -- 自动导包用这个
    vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action)
  end,
},

})
