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
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name) -- default handler (optional)
            require("lspconfig")[server_name].setup({
              on_attach = require("me.utils").on_attach,
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      vim.diagnostic.config({
        virtual_text = true,
        signs = true,
        underline = true,
        update_in_insert = false,
        severity_sort = true,
      })
    end,
  },
}