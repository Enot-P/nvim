local M = {}

--- Рекурсивная функция для обработки директорий
local function process_directory(dir_path)
  local dir_name = vim.fn.fnamemodify(dir_path, ":t")
  local target_file_name = dir_name .. ".dart"
  local exports = {}

  local entries = vim.fn.readdir(dir_path)

  for _, entry in ipairs(entries) do
    local full_entry_path = dir_path .. "/" .. entry

    if vim.fn.isdirectory(full_entry_path) == 1 then
      -- Рекурсивно заходим в подпапку
      local subdir_barrel = process_directory(full_entry_path)
      if subdir_barrel then
        table.insert(exports, string.format("export '%s/%s';", entry, subdir_barrel))
      end
    elseif entry:match("%.dart$") and entry ~= target_file_name then
      -- Добавляем только dart файлы (кроме самого барел-файла)
      table.insert(exports, string.format("export '%s';", entry))
    end
  end

  -- Создаем файл только если есть что экспортировать
  if #exports > 0 then
    local new_file_path = dir_path .. "/" .. target_file_name
    local file = io.open(new_file_path, "w")
    if file then
      table.sort(exports)
      file:write(table.concat(exports, "\n") .. "\n")
      file:close()
      return target_file_name
    end
  end
  return nil
end

--- Главная функция экспорта для вызова из Snacks Picker
M.generate_exports = function(picker)
  local item = picker:current()
  if not (item and item.file) then
    Snacks.notify.error("Не удалось определить путь в проводнике")
    return
  end

  -- Определяем стартовую папку (если под курсором файл — берем его папку)
  local start_path = vim.fn.isdirectory(item.file) == 1 and item.file or vim.fn.fnamemodify(item.file, ":p:h")

  local main_barrel = process_directory(start_path)

  if main_barrel then
    local full_path = start_path .. "/" .. main_barrel
    vim.schedule(function()
      vim.cmd("edit! " .. vim.fn.fnameescape(full_path))
    end)
    Snacks.notify.info("Рекурсивный экспорт готов: " .. main_barrel)
  else
    Snacks.notify.warn("Dart файлы для экспорта не найдены")
  end
end

return M
