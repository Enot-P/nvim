return {
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      -- list of servers for mason to install
      ensure_installed = {
        "lua_ls",
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
        -- "dart_format", -- Для форматирования dart согласно доке
        -- "dcm_fix", -- Для автоматического fix, также подсвечивает analys options ограничения если таковые заданы        "luacheck", -- Для линтинга Lua
      },
    },
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
}
