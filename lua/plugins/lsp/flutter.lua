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

    -- Хоткеи для Flutter
    vim.keymap.set("n", "<leader>flr", ":FlutterRun<CR>", { desc = "Flutter: Run" })
    vim.keymap.set("n", "<leader>flR", ":FlutterRestart<CR>", { desc = "Flutter: Restart" })
    vim.keymap.set("n", "<leader>flh", ":FlutterHotReload<CR>", { desc = "Flutter: Hot Reload" })
    vim.keymap.set("n", "<leader>flH", ":FlutterHotRestart<CR>", { desc = "Flutter: Hot Restart" })
    vim.keymap.set("n", "<leader>flq", ":FlutterQuit<CR>", { desc = "Flutter: Quit" })
    vim.keymap.set("n", "<leader>fld", ":FlutterDevices<CR>", { desc = "Flutter: Devices" })
    vim.keymap.set("n", "<leader>fle", ":FlutterEmulators<CR>", { desc = "Flutter: Emulators" })
    vim.keymap.set("n", "<leader>flo", ":FlutterOutline<CR>", { desc = "Flutter: Outline" })
    vim.keymap.set("n", "<leader>fls", ":FlutterSuper<CR>", { desc = "Flutter: Super" })
    vim.keymap.set("n", "<leader>flw", ":FlutterWidgetInspector<CR>", { desc = "Flutter: Widget Inspector" })
    vim.keymap.set("n", "<leader>flc", ":FlutterClearLogs<CR>", { desc = "Flutter: Clear Logs" })
  end,
}
