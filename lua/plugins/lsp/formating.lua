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
        -- Markdown
        markdown = { "prettier" },
        markdown_inline = { "prettier" },
        -- Kotlin
        kotlin = { "ktlint" },
        -- Java
        java = { "google-java-format" },
        -- TOML
        toml = { "taplo" },
        -- Docker - форматирование через LSP (dockerls) или можно не указывать
        -- hadolint это линтер, не форматтер, поэтому используем lsp_fallback
        -- Bash/Zsh
        bash = { "shfmt" },
        sh = { "shfmt" },
        zsh = { "shfmt" },
        -- SQL
        sql = { "sql-formatter" },
        -- GraphQL
        graphql = { "prettier" },
        -- Lua
        lua = { "stylua" },
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
