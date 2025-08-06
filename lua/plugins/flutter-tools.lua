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
          on_attach = function(client, bufnr)
            if client.name == "dartls" then
              vim.api.nvim_create_autocmd("BufWritePre", {
                group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
                buffer = bufnr,
                callback = function()
                  vim.lsp.buf.format({ async = true })
                end,
              })
            end
            local opts = { noremap = true, silent = true, buffer = bufnr }
            vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
            vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
            vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
            vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, opts)
            vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, opts)
            vim.keymap.set('n', 'gr', function() require('telescope.builtin').lsp_references() end, opts)
          end,
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
