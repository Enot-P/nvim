-- /lua/me/utils/utils_keymaps.lua
local M = {}

function M.setup()
  -- Загружаем утилиты напрямую, чтобы избежать циклической зависимости
  local data_class_gen = require("me.utils.dart_data_class_generate")
  local export_gen = require("me.utils.dart_export_file_generate")

  --
  -- Пользовательские команды для генерации Dart кода
  --
  vim.api.nvim_create_user_command("DartDataClass", data_class_gen.generate_data_class_interactive,
    { desc = "Интерактивная генерация data class методов" })

  vim.api.nvim_create_user_command("DartDataClassAll", function()
    data_class_gen.generate_data_class_methods({ toString = true, copyWith = true, equality = true })
  end, { desc = "Генерировать все data class методы" })

  vim.api.nvim_create_user_command("DartToString", function()
    data_class_gen.generate_data_class_methods({ toString = true, copyWith = false, equality = false })
  end, { desc = "Генерировать только toString" })

  vim.api.nvim_create_user_command("DartCopyWith", function()
    data_class_gen.generate_data_class_methods({ toString = false, copyWith = true, equality = false })
  end, { desc = "Генерировать только copyWith" })

  vim.api.nvim_create_user_command("DartEquality", function()
    data_class_gen.generate_data_class_methods({ toString = false, copyWith = false, equality = true })
  end, { desc = "Генерировать operator == и hashCode" })

  vim.api.nvim_create_user_command("DartConstructor", data_class_gen.generate_constructor,
    { desc = "Генерировать конструктор" })

  --
  -- Кеймапы
  --

  -- Кеймап для генерации экспортного файла (существующий)
  vim.keymap.set("n", "<leader>de", export_gen.generate_exports, { desc = "Dart: Сгенерировать экспортный файл" })

  -- Кеймапы для Dart файлов, которые создаются при открытии .dart файла
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "dart",
    callback = function()
      local opts = { buffer = true, desc = "" }

      -- Data Class генерация - главный интерактивный кеймап
      vim.keymap.set('n', '<leader>dc', data_class_gen.generate_data_class_interactive,
        vim.tbl_extend('force', opts, { desc = "Dart: Генерировать data class (интерактивно)" }))

      -- Быстрые кеймапы для отдельных методов
      vim.keymap.set('n', '<leader>da', function()
        data_class_gen.generate_data_class_methods({ toString = true, copyWith = true, equality = true })
      end, vim.tbl_extend('force', opts, { desc = "Dart: Генерировать все data class методы" }))

      vim.keymap.set('n', '<leader>dC', data_class_gen.generate_constructor,
        vim.tbl_extend('force', opts, { desc = "Dart: Генерировать конструктор" }))
    end,
  })
end

return M
