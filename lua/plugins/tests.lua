return {
  'vim-test/vim-test',
  config = function()
    -- Включить отладку
    vim.g['test#echo_command'] = 1

    -- ПРИНУДИТЕЛЬНО настроить Dart
    vim.g['test#enabled_runners'] = { 'dart#dart_test', 'dart#flutter_test' }

    -- Принудительно установить паттерны тестовых файлов для Dart
    vim.g['test#dart#file_pattern'] = '\\v.*_test\\.dart$'

    -- Принудительно установить паттерны для поиска тестов внутри файлов
    vim.g['test#dart#patterns'] = {
      test = {
        '\\v^\\s*test\\(',
        '\\v^\\s*testWidgets\\(',
      },
      namespace = {
        '\\v^\\s*group\\(',
      }
    }

    -- Настройка стратегии запуска
    vim.g['test#strategy'] = 'neovim'

    -- Настройки для Dart/Flutter
    vim.g['test#dart#runner'] = 'flutter_test'
    vim.g['test#dart#flutter_test#executable'] = 'flutter'
    vim.g['test#dart#flutter_test#options'] = '--no-sound-null-safety'
    vim.g['test#dart#dart_test#options'] = '--no-sound-null-safety'

    -- Кастомная функция для запуска Dart тестов (если vim-test не работает)
    local function run_dart_test_custom(scope)
      local current_file = vim.fn.expand('%')
      local relative_path = vim.fn.fnamemodify(current_file, ':.')

      if not current_file:match('_test%.dart$') then
        print("Это не тестовый файл Dart!")
        return
      end

      local cmd
      if scope == 'nearest' then
        -- Для ближайшего теста попробуем найти название теста под курсором
        local line = vim.api.nvim_get_current_line()
        local test_name = line:match("test%s*%(%s*['\"]([^'\"]+)['\"]")
        if test_name then
          cmd = string.format('flutter test %s -n "%s"', relative_path, test_name)
        else
          cmd = 'flutter test ' .. relative_path
        end
      elseif scope == 'file' then
        cmd = 'flutter test ' .. relative_path
      elseif scope == 'all' then
        cmd = 'flutter test'
      end

      print("Выполняю: " .. cmd)

      -- Запускаем команду
      vim.cmd('split | terminal ' .. cmd)
    end

    -- Горячие клавиши с fallback на кастомную функцию
    vim.keymap.set('n', '<leader>tsn', function()
      -- Сначала пробуем vim-test
      if vim.bo.filetype ~= 'dart' then
        vim.bo.filetype = 'dart'
      end

      -- Проверяем, распознается ли как тестовый файл
      local is_test = vim.fn['test#test_file'](vim.fn.expand('%'))
      if is_test == 1 then
        print("Используем vim-test...")
        vim.cmd('TestNearest')
      else
        print("vim-test не распознал файл, используем кастомную функцию...")
        run_dart_test_custom('nearest')
      end
    end, { desc = 'Run nearest test' })

    vim.keymap.set('n', '<leader>tsc', function()
      if vim.bo.filetype ~= 'dart' then
        vim.bo.filetype = 'dart'
      end

      local is_test = vim.fn['test#test_file'](vim.fn.expand('%'))
      if is_test == 1 then
        print("Используем vim-test...")
        vim.cmd('TestFile')
      else
        print("vim-test не распознал файл, используем кастомную функцию...")
        run_dart_test_custom('file')
      end
    end, { desc = 'Run current test file' })

    vim.keymap.set('n', '<leader>tsa', function()
      run_dart_test_custom('all')
    end, { desc = 'Run all tests' })

    vim.keymap.set('n', '<leader>tsl', '<cmd>TestLast<cr>', { desc = 'Run last test' })
    vim.keymap.set('n', '<leader>tsv', '<cmd>TestVisit<cr>', { desc = 'Visit last test file' })

    -- Отладочная информация
    vim.keymap.set('n', '<leader>tsi', function()
      local info = {}
      table.insert(info, "=== VIM-TEST DEBUG ===")
      table.insert(info, "Filetype: " .. vim.bo.filetype)
      table.insert(info, "Current file: " .. vim.fn.expand('%:p'))
      table.insert(info, "Working directory: " .. vim.fn.getcwd())

      -- Проверим, что vim-test видит файл как тестовый
      local current_file = vim.fn.expand('%')
      local is_test = vim.fn['test#test_file'](current_file)
      table.insert(info, "Is test file: " .. tostring(is_test == 1))

      -- Попробуем определить runner
      local runner = vim.fn['test#determine_runner'](current_file)
      table.insert(info, "Determined runner: " .. tostring(runner))

      -- Проверим паттерны
      table.insert(info, "File extension: " .. vim.fn.expand('%:e'))
      table.insert(info, "File name: " .. vim.fn.expand('%:t'))
      table.insert(info, "===================")

      -- Покажем через vim.notify и echo
      local msg = table.concat(info, "\n")
      vim.cmd('echo "' .. msg:gsub('"', '\\"') .. '"')

      -- Также выведем каждую строку отдельно для надежности
      for _, line in ipairs(info) do
        print(line)
      end
    end, { desc = 'Debug info' })

    -- Автоматически установить filetype для .dart файлов
    vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
      pattern = "*.dart",
      callback = function()
        vim.bo.filetype = "dart"
      end
    })
  end
}
