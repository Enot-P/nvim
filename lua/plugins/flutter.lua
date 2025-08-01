return {
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require("lspconfig")

      -- Настройка dartls
      lspconfig.dartls.setup({
        cmd = {
          vim.fn.expand("$HOME/develop/flutter/bin/cache/dart-sdk/bin/dart"),
          "language-server",
          "--protocol=lsp",
        },
        root_dir = lspconfig.util.root_pattern("pubspec.yaml", ".git"),
        settings = {
          dart = {
            completeFunctionCalls = true,
            showTodos = true,
          },
        },
      })

      -- Автоформатирование при сохранении
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.dart",
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },

  -- cmp + luasnip + flutter snippets
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "Nash0x7E2/awesome-flutter-snippets",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      -- Загружаем Flutter/Dart сниппеты
      require("luasnip.loaders.from_vscode").lazy_load({
        paths = { vim.fn.stdpath("data") .. "/lazy/awesome-flutter-snippets" },
      })

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = cmp.mapping.preset.insert({
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),

          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
        },
      })
    end,
  },
}
