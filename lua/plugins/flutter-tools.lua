return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/conform.nvim", -- For formatting
    "hrsh7th/cmp-nvim-lsp", -- For LSP capabilities
  },
  config = function()
    require("flutter-tools").setup {
      widget_guides = {
        enabled = true,
      },
      lsp = {
        on_attach = require("plugins.lsp").on_attach,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        settings = {
          dart = {
            analysisExcludedFolders = {
              vim.fn.expand("$HOME/AppData/Local/Pub/Cache"),
              vim.fn.expand("$HOME/.pub-cache"),
              vim.fn.expand("/opt/homebrew/"),
              vim.fn.expand("$HOME/tools/flutter/"),
              vim.fn.expand("$HOME/development/sdks/flutter/packages"),
              vim.fn.expand("$HOME/development/sdks/flutter/.pub-cache"),
            },
            updateImportsOnRename = true,
            completeFunctionCalls = true,
            showTodos = true,
          },
        },
      },
    }
  end,
}
