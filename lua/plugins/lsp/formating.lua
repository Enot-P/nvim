return {
  "stevearc/conform.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    local conform = require("conform")
    conform.setup({
      formatters_by_ft = {
        -- Dart/Flutter - использует встроенный форматтер через LSP (dartls)
        -- Если нужен явный форматтер, можно раскомментировать: dart = { "dart_format" }
        -- Но лучше использовать lsp_fallback = true (уже включено ниже)
        -- JSON
        json = { "prettier" },
        jsonc = { "prettier" },
        -- YAML
        yaml = { "prettier" },
        -- TOML
        toml = { "taplo" },
        -- SQL
        sql = { "sql_formatter" },
        lua = { "stylua" },
      },
      formatters = {
        sql_formatter = {
          prepend_args = {
            "-c", -- правильный флаг

            vim.fn.expand("~/.config/nvim/lua/.sql-formatter.json"),
          },
        },
      },
      format_on_save = {
        lsp_fallback = true,
        async = false,
        timeout_ms = 3000,
      },
    })

    vim.keymap.set({ "n", "v" }, "<leader>mp", function()
      conform.format({
        lsp_fallback = true,
        async = false,
        timeout_ms = 1000,
      })
    end, { desc = "Format file or range (in visual mode)" })
  end,
}
