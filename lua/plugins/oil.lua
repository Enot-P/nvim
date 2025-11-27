return {
  'stevearc/oil.nvim',
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    require("oil").setup({
      -- Делаем Oil основным файловым менеджером (перехватывает netrw)
      default_file_explorer = true,
      -- Oil будет принимать во внимание .gitignore файлы
      view_options = {
        show_hidden = false,
        is_hidden_file = function(name, bufnr)
          return vim.startswith(name, ".")
        end,
        is_always_hidden = function(name, bufnr)
          return false
        end,
        sort = {
          { "type", "asc" },
          { "name", "asc" },
        },
      },
      -- Настройки для работы с буфером
      buf_options = {
        buflisted = false,
        bufhidden = "hide",
      },
      -- Настройки окна
      win_options = {
        wrap = false,
        signcolumn = "no",
        cursorcolumn = false,
        foldcolumn = "0",
        spell = false,
        list = false,
        conceallevel = 3,
        concealcursor = "nvic",
      },
      -- Настройки удаления
      delete_to_trash = false,
      skip_confirm_for_simple_edits = false,
      prompt_save_on_select_new_entry = true,
      cleanup_delay_ms = 2000,
      lsp_file_methods = {
        -- Включить LSP file operations
        timeout_ms = 1000,
        autosave_changes = false,
      },
      constrain_cursor = "editable",
      experimental_watch_for_changes = false,
      -- Кастомные кейбинды
      keymaps = {
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.select",
        ["<C-s>"] = "actions.select_vsplit",
        ["<C-h>"] = "actions.select_split",
        ["<C-t>"] = "actions.select_tab",
        ["<C-p>"] = "actions.preview",
        ["<C-c>"] = "actions.close",
        ["<C-l>"] = "actions.refresh",
        ["-"] = "actions.parent",
        ["_"] = "actions.open_cwd",
        ["`"] = "actions.cd",
        ["~"] = "actions.tcd",
        ["gs"] = "actions.change_sort",
        ["gx"] = "actions.open_external",
        ["g."] = "actions.toggle_hidden",
        ["g\\"] = "actions.toggle_trash",
      },
      -- Используем select для встроенных команд
      use_default_keymaps = true,
      -- Настройки для предпросмотра
      preview = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = 0.9,
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        win_options = {
          winblend = 0,
        },
      },
      -- Настройки прогресс-бара
      progress = {
        max_width = 0.9,
        min_width = { 40, 0.4 },
        width = nil,
        max_height = { 10, 0.9 },
        min_height = { 5, 0.1 },
        height = nil,
        border = "rounded",
        minimized_border = "none",
        win_options = {
          winblend = 0,
        },
      },
    })

    -- Интеграция генератора BLoC/Cubit: локальные маппинги в буфере Oil
    local function map_oil_bloc_actions(bufnr)
      local ok, oil = pcall(require, "oil")
      if not ok then return end
      local dir = oil.get_current_dir()
      if not dir then return end

      local function target_dir()
        -- Если курсор на элементе, используем папку элемента или родителя
        local entry = oil.get_cursor_entry()
        if entry then
          if entry.type == "directory" then
            return require('oil').get_current_dir() .. entry.name
          else
            return require('oil').get_current_dir()
          end
        end
        return dir
      end

      -- Никаких прямых b/c/gd биндов в буфере Oil — по запросу пользователя
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'oil',
      callback = function(args)
        map_oil_bloc_actions(args.buf)
      end,
    })

    -- Глобальная команда/ключ: <leader>dgb — меню выбора генерации в текущей Oil директории
    local function oil_generate_menu()
      local ok, oil = pcall(require, 'oil')
      if not ok then
        vim.notify('Oil не загружен', vim.log.levels.ERROR)
        return
      end
      local dir = oil.get_current_dir() or vim.fn.expand('%:p:h')
      local entry = oil.get_cursor_entry()
      if entry and entry.type == 'directory' then
        if not dir:match('/$') then dir = dir .. '/' end
        dir = dir .. entry.name
      end
      local gen = require('me.utils.bloc_generate')
      local choices = { 'Bloc', 'Cubit' }
      vim.ui.select(choices, { prompt = 'Что сгенерировать в: ' .. dir }, function(choice)
        if not choice then return end
        if choice == 'Bloc' then
          gen.create_bloc_at(dir)
        else
          gen.create_cubit_at(dir)
        end
      end)
    end

    vim.keymap.set('n', '<leader>dgb', oil_generate_menu, { desc = 'Dart: Generate Bloc/Cubit in Oil dir' })

    -- Функция для обновления импортов после переименования
    local function update_dart_imports_on_rename(old_path, new_path)
      -- Получаем имена файлов без путей
      local old_name = vim.fn.fnamemodify(old_path, ":t:r") -- без расширения
      local new_name = vim.fn.fnamemodify(new_path, ":t:r") -- без расширения

      if old_name == new_name then
        return -- Имя не изменилось
      end

      -- Ищем все .dart файлы в проекте
      local cmd = string.format("rg -l \"import.*%s\\.dart\" --type dart .", old_name)
      local files = vim.fn.systemlist(cmd)

      for _, file in ipairs(files) do
        -- Читаем файл
        local lines = vim.fn.readfile(file)
        local changed = false

        for i, line in ipairs(lines) do
          -- Заменяем импорты
          local new_line = line:gsub("import%s+['\"](.-)/" .. old_name .. "%.dart['\"]",
            "import '%1/" .. new_name .. ".dart'")
          if new_line ~= line then
            lines[i] = new_line
            changed = true
          end

          -- Заменяем экспорты
          new_line = lines[i]:gsub("export%s+['\"](.-)/" .. old_name .. "%.dart['\"]",
            "export '%1/" .. new_name .. ".dart'")
          if new_line ~= lines[i] then
            lines[i] = new_line
            changed = true
          end
        end

        -- Сохраняем файл если были изменения
        if changed then
          vim.fn.writefile(lines, file)
          vim.notify("Updated imports in: " .. file, vim.log.levels.INFO)
        end
      end
    end

    -- Автокоманда для отслеживания переименований файлов
    vim.api.nvim_create_autocmd("User", {
      pattern = "OilActionsPost",
      callback = function(args)
        if args.data and args.data.actions then
          for _, action in ipairs(args.data.actions) do
            if action.type == "move" and vim.fn.fnamemodify(action.src_path, ":e") == "dart" then
              update_dart_imports_on_rename(action.src_path, action.dest_path)
            end
          end
        end
      end,
    })

    -- Кейбинды для oil
    -- vim.keymap.set("n", "<leader>e", "<CMD>Oil<CR>", { desc = "Открыть файловый менеджер Oil" })
    vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Открыть Oil в текущей директории" })

    -- Команда для переименования файла с обновлением импортов
    vim.api.nvim_create_user_command("RenameFile", function(opts)
      local current_file = vim.fn.expand("%:p")
      local current_dir = vim.fn.expand("%:p:h")
      local new_name = opts.args

      if new_name == "" then
        vim.ui.input({ prompt = "Новое имя файла: " }, function(input)
          if input then
            local old_path = current_file
            local new_path = current_dir .. "/" .. input

            -- Переименовываем файл
            vim.fn.rename(old_path, new_path)

            -- Обновляем буфер
            vim.cmd("edit " .. new_path)

            -- Обновляем импорты
            update_dart_imports_on_rename(old_path, new_path)

            vim.notify("Файл переименован: " .. input, vim.log.levels.INFO)
          end
        end)
      else
        local old_path = current_file
        local new_path = current_dir .. "/" .. new_name

        vim.fn.rename(old_path, new_path)
        vim.cmd("edit " .. new_path)
        update_dart_imports_on_rename(old_path, new_path)

        vim.notify("Файл переименован: " .. new_name, vim.log.levels.INFO)
      end
    end, { nargs = "?", desc = "Переименовать файл с обновлением импортов" })
  end,
}
