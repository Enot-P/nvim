return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
    "mfussenegger/nvim-dap", -- для интеграции с дебаггером
  },
  config = function()
    require("flutter-tools").setup({
      debugger = {
        -- Включаем интеграцию с nvim-dap
        enabled = true,
        -- Остановка на исключениях (пустой список = не останавливаться на исключениях)
        exception_breakpoints = {},
        -- Вызывать toString() на объектах в debug views (hover, variables list)
        -- Это может замедлить работу, но полезно для отладки
        evaluate_to_string_in_debug_views = true,
        -- flutter-tools автоматически регистрирует конфигурации DAP для Dart/Flutter
        -- Можно переопределить через register_configurations, если нужны кастомные настройки
        -- register_configurations = function(paths)
        --   require("dap").configurations.dart = {
        --     {
        --       type = "dart",
        --       request = "launch",
        --       name = "Launch Flutter",
        --       program = "${workspaceFolder}/lib/main.dart",
        --       cwd = "${workspaceFolder}",
        --     }
        --   }
        -- end,
      },
      -- Другие настройки можно добавить здесь при необходимости
    })
  end,
}
