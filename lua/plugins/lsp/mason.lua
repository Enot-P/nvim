return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
        "ts_ls", -- TypeScript/JavaScript
        "jsonls", -- JSON
        "kotlin_language_server", -- Kotlin
        "jdtls", -- Java
        "yamlls", -- YAML
        "taplo", -- TOML
        "dockerls", -- Dockerfile
        "bashls", -- Bash
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
        "stylua", -- Для lua
        "luacheck", -- Для lua
        "prettier", -- Для большинства языков
        "dart-debug-adapter", -- Для отладки Dart/Flutter
        -- "dart_format", -- Для форматирования dart согласно доке
        -- "dcm_fix", -- Для автоматического fix, также подсвечивает analys options ограничения если таковые заданы        "luacheck", -- Для линтинга Lua
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
