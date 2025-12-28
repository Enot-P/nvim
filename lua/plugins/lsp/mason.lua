return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        -- Dart/Flutter управляется через flutter-tools.nvim, не добавляем сюда
        "ts_ls", -- TypeScript/JavaScript
        "jsonls", -- JSON
        "kotlin_language_server", -- Kotlin
        "jdtls", -- Java
        "yamlls", -- YAML
        "taplo", -- TOML
        "dockerls", -- Dockerfile
        "bashls", -- Bash/Zsh
        "sqlls", -- SQL
        "graphql", -- GraphQL
        "html", -- HTML
        "cssls", -- CSS
        "marksman", -- Markdown
        "vimls", -- Vim
      },
      handlers = {
        -- default handler for all servers
        function(server_name)
          require("lspconfig")[server_name].setup({})
        end,
      },
    },
    dependencies = {
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = {
      ensure_installed = {
        -- Форматтеры
        "stylua", -- Для lua
        "prettier", -- Для JSON, YAML, Markdown, GraphQL
        "taplo", -- Для TOML
        "shfmt", -- Для Bash/Zsh
        "google-java-format", -- Для Java
        "ktlint", -- Для Kotlin
        "sql-formatter", -- Для SQL
        "dart-debug-adapter", -- Для отладки Dart/Flutter
        -- Линтеры
        "luacheck", -- Для линтинга Lua
        "hadolint", -- Для Dockerfile
        "shellcheck", -- Для Bash/Zsh
        "yamllint", -- Для YAML
        "jsonlint", -- Для JSON
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
