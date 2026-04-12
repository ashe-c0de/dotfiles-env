-- ==========================================================================
-- 基础设置
-- ==========================================================================
vim.g.mapleader = " "

vim.opt.backupcopy = "yes"
vim.opt.shada = "'100,<50,s10,h"
vim.opt.swapfile = false
vim.opt.timeoutlen = 300

-- Mac clipboard
vim.opt.clipboard = "unnamedplus"

-- UI
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.termguicolors = true

-- ==========================================================================
-- Keymaps
-- ==========================================================================
vim.keymap.set('n', '<leader>w', function()
  if vim.bo.buftype == "" and vim.bo.modifiable then
    vim.cmd("write")
  else
    vim.api.nvim_echo({{"当前窗口不可保存", "WarningMsg"}}, false, {})
  end
end, { desc = "Save File" })

vim.keymap.set("n", "<leader>q", "<cmd>q<CR>")

-- quickfix 关闭
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "qf" },
  callback = function()
    vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = true })
  end,
})

-- ==========================================================================
-- Lazy.nvim
-- ==========================================================================
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git","clone","--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- ==========================================================================
  -- Treesitter（仅 Go）
  -- ==========================================================================
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function()
      require("nvim-treesitter.configs").setup({
        ensure_installed = { "go" },
        highlight = {
          enable = true,
          disable = function(_, buf)
            local max = 100 * 1024
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            return ok and stats and stats.size > max
          end,
        },
        indent = { enable = true },
      })
    end,
  },

  -- ==========================================================================
  -- CMP
  -- ==========================================================================
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
    },
    config = function()
      local cmp = require("cmp")
      cmp.setup({
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "buffer" },
          { name = "path" },
        },
      })
    end,
  },

  -- ==========================================================================
  -- LSP（仅 Go）
  -- ==========================================================================
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lsp = require("lspconfig")
      local cap = require("cmp_nvim_lsp").default_capabilities()

      lsp.gopls.setup({
        capabilities = cap,
        settings = {
          gopls = {
            completeUnimported = true,
            staticcheck = true,
            usePlaceholders = true,
          },
        },
      })

      local opts = { noremap = true, silent = true }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
    end,
  },

  -- ==========================================================================
  -- Format（仅 Go）
  -- ==========================================================================
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = {
      formatters_by_ft = {
        go = { "goimports", "gofmt" },
      },
      default_format_opts = {
        lsp_format = "fallback",
      },
    },
    keys = {
      {
        "<leader>fl",
        function()
          require("conform").format({ async = false })
        end,
        desc = "Format",
      },
    },
  },

  -- ==========================================================================
  -- Neo-tree
  -- ==========================================================================
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
          },
        },
      })
      vim.keymap.set("n", "<leader>e", "<cmd>Neotree toggle<CR>")
    end,
  },

  -- ==========================================================================
  -- Telescope
  -- ==========================================================================
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files)
      vim.keymap.set("n", "<leader>fg", builtin.live_grep)
    end,
  },

  -- ==========================================================================
  -- Project
  -- ==========================================================================
  {
    "ahmedkhalf/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    config = function()
      require("project_nvim").setup({
        detection_methods = { "pattern" },
        patterns = { ".git", "go.mod" },
      })
      require("telescope").load_extension("projects")
      vim.keymap.set("n", "<leader>fp", "<cmd>Telescope projects<CR>")
    end,
  },

  -- ==========================================================================
  -- Theme
  -- ==========================================================================
  {
    "neanias/everforest-nvim",
    priority = 1000,
    config = function()
      require("everforest").setup({
        background = "soft",
        ui_contrast = "low",
      })
      vim.cmd("colorscheme everforest")
    end,
  },

  -- ==========================================================================
  -- UI
  -- ==========================================================================
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("noice").setup({})
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = { theme = "auto", globalstatus = true },
      })
    end,
  },

  -- ==========================================================================
  -- DAP（Go）
  -- ==========================================================================
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "leoluz/nvim-dap-go",
      "nvim-neotest/nvim-nio",
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      require("dap-go").setup()
      dapui.setup()

      dap.listeners.after.event_initialized["dapui"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui"] = function()
        dapui.close()
      end

      vim.keymap.set("n", "<F5>", dap.continue)
      vim.keymap.set("n", "<F10>", dap.step_over)
      vim.keymap.set("n", "<F11>", dap.step_into)
      vim.keymap.set("n", "<F12>", dap.step_out)
      vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)
    end,
  },

})
