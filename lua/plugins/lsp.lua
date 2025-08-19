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
      -- In your lsp.lua file, modify mason-lspconfig setup:
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            -- Skip dartls as it's handled by flutter-tools
            if server_name == "dartls" then
              return
            end

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
      -- In your lsp.lua, update diagnostic config:
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false, -- This is good - keeps it false
        severity_sort = true,
        float = {
          focusable = false,
          style = "minimal",
          border = "rounded",
          source = "always",
          header = "",
          prefix = "",
        },
      })
    end,
  },
}

