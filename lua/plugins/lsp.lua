return {
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    config = function()
      require("mason-lspconfig").setup()
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(client, bufnr)
        if client.name == "dartls" then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("LspFormat", { clear = true }),
            buffer = bufnr,
            callback = function()
              vim.lsp.buf.format({ async = true })
            end,
          })
        end
        vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { buffer = bufnr, desc = "Перейти к определению" })
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "Показать документацию" })
        vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, { buffer = bufnr, desc = "Перейти к реализации" })
        vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = bufnr, desc = "Переименовать" })
        vim.keymap.set('n', 'ca', vim.lsp.buf.code_action, { buffer = bufnr, desc = "Действия с кодом" })
        vim.keymap.set('n', 'gr', vim.lsp.buf.references, { buffer = bufnr, desc = "Показать использования" })
      end

      -- lspconfig.dartls.setup({
      --   on_attach = on_attach,
      --   capabilities = capabilities,
      --   settings = {
      --     dart = {
      --       lineLength = 80,
      --       flutterOutline = true,
      --       closingLabels = true,
      --     }
      --   }
      -- })
    end,
  },
}
