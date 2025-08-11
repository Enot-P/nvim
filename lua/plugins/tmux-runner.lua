return {
  "christoomey/vim-tmux-runner",
  config = function()
    local function send_key_to_flutter_window(key)
      -- Получаем информацию о текущем окне
      local current_window = vim.fn.system("tmux display-message -p '#I'"):gsub("\n", "")

      -- Получаем список всех окон
      local windows_info = vim.fn.system("tmux list-windows -F '#{window_index} #{window_active} #{window_name}'")

      local target_window = nil

      -- Ищем окна и определяем целевое
      for line in windows_info:gmatch("[^\r\n]+") do
        local win_index, is_active, win_name = line:match("([0-9]+)%s+([01])%s+(.*)")

        if win_index and is_active == "0" then
          --Берем первое неактивное окно как целевое
          if not target_window then
            target_window = win_index
          end

          -- Или ищем окно с Flutter (если есть характерные названия)
          if win_name and (win_name:match("[Ff]lutter") or win_name:match("[Dd]art")) then
            target_window = win_index
          end
        end
      end

      -- Отправляем команду в целевое окно
      if target_window then
        local cmd = string.format("tmux send-keys -t %s %s Enter", target_window, key)
        vim.fn.system(cmd)
      else
        -- Пробуем отправить в следующее окно
        local next_window = tonumber(current_window) + 1
        local cmd = string.format("tmux send-keys -t %s %s Enter 2>/dev/null", next_window, key)

        if vim.v.shell_error ~= 0 then
          -- Пробуем предыдущее окно
          local prev_window = tonumber(current_window) - 1
          if prev_window > 0 then
            cmd = string.format("tmux send-keys -t %s %s Enter", prev_window, key)
            vim.fn.system(cmd)
          end
        end
      end
    end

    local function dart_hot_reload()
      send_key_to_flutter_window("'r'")
    end

    -- Функция для получения информации о Flutter процессе из tmux
    local function get_flutter_process_info()
      local handle = io.popen("tmux capture-pane -t 1 -p | grep -A5 -B5 'A Dart VM Service'")
      if handle then
        local output = handle:read("*a")
        handle:close()
        return output
      end
      return nil
    end

    -- Функция для извлечения VM Service URI
    local function extract_vm_service_uri()
      local flutter_info = get_flutter_process_info()
      if flutter_info then
        local uri = flutter_info:match("http://[%d%.]+:%d+/[%w%-_]+=/")
        return uri
      end
      return nil
    end

    -- Функция для показа Flutter debug информации
    local function show_flutter_debug_info()
      local handle = io.popen(
      "tmux capture-pane -t 1 -p | grep -E '(A Dart VM Service|Flutter DevTools|Hot reload|Hot restart)' | tail -10")
      if handle then
        local output = handle:read("*a")
        handle:close()

        print("=== Flutter Debug Information ===")
        if output and output ~= "" then
          print(output)

          -- Извлекаем и показываем основную информацию
          local vm_uri = output:match("(http://[%d%.]+:%d+/[%w%-_]+=/)")
          local devtools_uri = output:match("(http://[%d%.]+:%d+%?uri=http://[%d%.]+:%d+/[%w%-_]+=/)")

          if vm_uri then
            print("VM Service URI: " .. vm_uri)
          end
          if devtools_uri then
            print("DevTools URI: " .. devtools_uri)
          end
        else
          print("Информация о Flutter процессе не найдена")
          print("Убедитесь, что flutter run запущен во второй вкладке tmux")
        end
      end
    end

    -- Функция для быстрого подключения отладчика
    local function quick_debug_attach()
      local uri = extract_vm_service_uri()
      if uri then
        print("Подключаемся к: " .. uri)
        -- Вызываем команду Flutter для подключения отладчика
        vim.cmd("FlutterAttach")
      else
        print("Не удалось найти VM Service URI")
        show_flutter_debug_info()
      end
    end

    -- Автокоманда для сохранения dart файлов
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = "*.dart",
      callback = dart_hot_reload,
      desc = "Dart hot reload on save",
    })

    -- Команда для ручного вызова
    vim.api.nvim_create_user_command("DartHotReload", dart_hot_reload, {
      desc = "Manual dart hot reload"
    })

    -- Команда для просмотра окон tmux
    vim.api.nvim_create_user_command("TmuxWindows", function()
      local windows = vim.fn.system("tmux list-windows -F '#{window_index}: #{window_name} #{?window_active,(active),}'")
      print("Tmux окна:")
      print(windows)
    end, {
      desc = "Show tmux windows"
    })

    -- Новые команды для работы с отладкой
    vim.api.nvim_create_user_command("FlutterDebugInfo", show_flutter_debug_info, {
      desc = "Show Flutter debug information from tmux"
    })

    vim.api.nvim_create_user_command("QuickDebugAttach", quick_debug_attach, {
      desc = "Quick attach to running Flutter process"
    })

    -- Команда для открытия DevTools в браузере
    vim.api.nvim_create_user_command("FlutterDevTools", function()
      local flutter_info = get_flutter_process_info()
      if flutter_info then
        local devtools_uri = flutter_info:match("(http://[%d%.]+:%d+%?uri=http://[%d%.]+:%d+/[%w%-_]+=/)")
        if devtools_uri then
          -- Попытка открыть в браузере (Linux/macOS)
          local open_cmd = vim.fn.has('mac') == 1 and 'open' or 'xdg-open'
          vim.fn.system(open_cmd .. ' "' .. devtools_uri .. '"')
          print("Открываем DevTools: " .. devtools_uri)
        else
          print("DevTools URI не найден")
          show_flutter_debug_info()
        end
      end
    end, {
      desc = "Open Flutter DevTools in browser"
    })

    -- Keymaps
    vim.keymap.set('n', '<leader>fr', dart_hot_reload, { desc = 'Dart hot reload' })
    vim.keymap.set('n', '<leader>fi', function() send_key_to_flutter_window("'i'") end, { desc = 'Инспектор виджетов' })
    vim.keymap.set('n', '<leader>fp', function() send_key_to_flutter_window("'p'") end, { desc = 'Линии построения' })

    -- Новые keymaps для отладки
    vim.keymap.set('n', '<leader>fD', show_flutter_debug_info, { desc = 'Show Flutter debug info' })
    vim.keymap.set('n', '<leader>fA', quick_debug_attach, { desc = 'Quick attach debugger' })
    vim.keymap.set('n', '<leader>ft', '<cmd>FlutterDevTools<cr>', { desc = 'Open DevTools' })

    -- Дополнительные горячие клавиши для flutter run
    vim.keymap.set('n', '<leader>fR', function() send_key_to_flutter_window("'R'") end, { desc = 'Hot restart' })
    vim.keymap.set('n', '<leader>fh', function() send_key_to_flutter_window("'h'") end, { desc = 'Help commands' })
    vim.keymap.set('n', '<leader>fc', function() send_key_to_flutter_window("'c'") end, { desc = 'Clear screen' })
    vim.keymap.set('n', '<leader>fd', function() send_key_to_flutter_window("'d'") end, { desc = 'Detach' })
  end,
}
