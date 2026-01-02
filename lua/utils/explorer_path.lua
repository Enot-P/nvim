local M = {}

-- Функция для создания файла с именем папки
M.create_file_with_dir_name = function(dir_path)
  if not dir_path or dir_path == "" then
    Snacks.notify.error("Путь не найден")
    return
  end

  -- Извлекаем имя папки
  local dir_name = vim.fn.fnamemodify(dir_path, ":t")
  -- Формируем путь (используем / независимо от ОС, Neovim это понимает)
  local new_file_path = dir_path .. "/" .. dir_name .. ".dart"

  -- "w" перезапишет файл, если он есть
  local file = io.open(new_file_path, "w")
  if file then
    file:write("") -- Создаем пустой файл
    file:close()

    -- vim.schedule(function()
    --   vim.cmd("edit " .. vim.fn.fnameescape(new_file_path))
    -- end)

    Snacks.notify.info("Файл " .. dir_name .. ".dart готов")
  else
    Snacks.notify.error("Ошибка записи файла")
  end
end

M.save_path_from_picker = function(picker)
  local item = picker:current()

  if item and item.file then
    local full_path = item.file
    local dir_path = vim.fn.isdirectory(full_path) == 1 and full_path or vim.fn.fnamemodify(full_path, ":p:h")

    -- Передаем путь напрямую в функцию создания
    M.create_file_with_dir_name(dir_path)
    return dir_path
  else
    Snacks.notify.error("Не удалось определить путь в Picker")
  end
end

return M
