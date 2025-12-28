return {
  "nvim-flutter/flutter-tools.nvim",
  lazy = false,
  dependencies = {
    "nvim-lua/plenary.nvim",
    "stevearc/dressing.nvim", -- optional for vim.ui.select
    "mfussenegger/nvim-dap", -- для интеграции с дебаггером
  },
  config = function()
    -- Путь к файлу для логов Flutter
    local log_file = vim.fn.tempname() .. "_flutter.log"
    local tmux_pane_created = false
    
    -- Создаем файл логов заранее
    local file = io.open(log_file, "w")
    if file then
      file:close()
    end
    
    -- Функция фильтра для записи логов в файл
    local function log_filter(log_line)
      if log_line then
        -- Записываем лог в файл
        local file = io.open(log_file, "a")
        if file then
          file:write(log_line .. "\n")
          file:flush() -- Принудительно записываем в файл
          file:close()
        end
      end
      -- Возвращаем true, чтобы логи также отображались в буфере Neovim (если нужно)
      return true
    end
    
    -- Функция для создания нового окна tmux с логами (как вкладка в браузере)
    local function create_tmux_log_window()
      -- Проверяем, что мы в tmux сессии
      if vim.env.TMUX == nil then
        vim.notify("Не в tmux сессии. Логи будут отображаться только в Neovim буфере.", vim.log.levels.WARN)
        return
      end
      
      -- Проверяем, не создано ли уже окно
      if tmux_pane_created then
        return
      end
      
      -- Создаем новое окно tmux (как вкладку в браузере)
      -- и запускаем tail -f для мониторинга файла логов
      -- tmux new-window принимает команду как строку в кавычках
      local cmd = string.format(
        "tmux new-window -n 'Flutter Logs' 'tail -f %s'",
        vim.fn.shellescape(log_file)
      )
      
      -- Выполняем команду через системный вызов
      -- Используем vim.fn.system для синхронного выполнения
      local result = vim.fn.system(cmd)
      if vim.v.shell_error == 0 then
        tmux_pane_created = true
        vim.notify("Окно tmux с логами Flutter создано (можно переключиться через Ctrl-a + номер окна)", vim.log.levels.INFO)
      else
        vim.notify("Не удалось создать окно tmux: " .. (result or "неизвестная ошибка"), vim.log.levels.ERROR)
      end
    end
    
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
      dev_log = {
        enabled = true,
        -- Фильтр для записи логов в файл
        filter = log_filter,
        -- Уведомлять об ошибках
        notify_errors = true,
        -- Открываем буфер в Neovim (нужен для работы плагина)
        -- Но мы также создадим новое окно tmux через автокоманду
        open_cmd = "15split",
        -- Не фокусироваться на окне логов в Neovim (так как они в новом окне tmux)
        focus_on_open = false,
      },
      -- Другие настройки можно добавить здесь при необходимости
    })
    
    -- Автокоманда для создания нового окна tmux когда открывается буфер логов Flutter
    vim.api.nvim_create_autocmd("BufEnter", {
      pattern = "__FLUTTER_DEV_LOG__",
      callback = function()
        -- Небольшая задержка, чтобы файл успел начать заполняться
        vim.defer_fn(function()
          create_tmux_log_window()
        end, 500)
      end,
      once = true, -- Выполнить только один раз
    })
    
    -- Автокоманда для очистки файла логов при очистке буфера Flutter
    -- Используем событие BufWritePost для буфера логов как альтернативу
    vim.api.nvim_create_autocmd("BufWipeout", {
      pattern = "__FLUTTER_DEV_LOG__",
      callback = function()
        -- Очищаем файл логов при закрытии буфера
        local file = io.open(log_file, "w")
        if file then
          file:close()
        end
        tmux_pane_created = false -- Сбрасываем флаг
      end,
    })
    
    -- Команда для ручного создания нового окна tmux с логами
    vim.api.nvim_create_user_command("FlutterTmuxLogs", function()
      tmux_pane_created = false -- Сбрасываем флаг, чтобы можно было создать новое окно
      create_tmux_log_window()
    end, {
      desc = "Создать новое окно tmux с логами Flutter (как вкладку)",
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
