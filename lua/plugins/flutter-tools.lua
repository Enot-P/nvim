return {
  "akinsho/flutter-tools.nvim",
  lazy = false,
  ft = "dart",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/conform.nvim", -- For formatting
  },
  config = function()
    require("flutter-tools").setup {
      widget_guides = {
        enabled = true,
      },
      lsp = {
        on_attach = require("plugins.lsp").on_attach,
        capabilities = require("plugins.lsp").capabilities,
      },
    }
  end,
}