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
    
    -- Keymap для быстрого вызова
    vim.keymap.set('n', '<leader>fr', dart_hot_reload, { desc = 'Dart hot reload' })
    vim.keymap.set('n', '<leader>fi', function() send_key_to_flutter_window("'i'") end, { desc = 'Инспектор виджетов' })
    vim.keymap.set('n', '<leader>fp', function() send_key_to_flutter_window("'p'") end, { desc = 'Линии построения' })
  end,
}
