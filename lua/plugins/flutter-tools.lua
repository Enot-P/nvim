return {
  {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'stevearc/dressing.nvim', -- optional for ui select
    },
    config = function()
      require('flutter-tools').setup {
        lsp = {
          capabilities = require("cmp_nvim_lsp").default_capabilities(),
          settings = {
            dart = {
              lineLength = 80,
              flutterOutline = true,
              closingLabels = true,
            }
          }
        }
      }
    end
  }
}
