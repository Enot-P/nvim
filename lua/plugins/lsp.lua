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
      -- ВАЖНО: Исключаем dartls из автоматической обработки
      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            -- Пропускаем dartls - им управляет flutter-tools
            if server_name == "dartls" then
              return
            end

            -- Безопасная проверка наличия utils
            local utils_ok, utils = pcall(require, "me.utils")
            local on_attach_fn = utils_ok and utils.on_attach or function() end

            -- Безопасная проверка наличия cmp
            local cmp_ok, cmp_lsp = pcall(require, "cmp_nvim_lsp")
            local capabilities = cmp_ok and cmp_lsp.default_capabilities() or vim.lsp.protocol.make_client_capabilities()

            require("lspconfig")[server_name].setup({
              on_attach = on_attach_fn,
              capabilities = capabilities,
            })
          end,
        },
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      -- Обновленная конфигурация диагностики
      vim.diagnostic.config({
        virtual_text = {
          spacing = 4,
          source = "if_many",
          prefix = "●",
        },
        signs = true,
        underline = true,
        update_in_insert = false, -- Это важно для стабильности
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

      -- Простое подавление ошибок textDocument/didChange
      local original_handler = vim.lsp.handlers["window/showMessage"]
      vim.lsp.handlers["window/showMessage"] = function(err, result, ctx, config)
        -- Игнорируем сообщения об ошибках textDocument/didChange
        if result and result.message and result.message:match("textDocument/didChange") then
          return
        end
        if original_handler then
          return original_handler(err, result, ctx, config)
        end
      end
    end,
  },
}
