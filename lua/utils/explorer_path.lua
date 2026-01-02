local M = {}

M.save_path_from_picker = function(picker)
  local item = picker:current()

  if item and item.file then
    local full_path = item.file
    local dir_path

    -- Проверяем, является ли выбранный элемент директорией
    -- (В Snacks Explorer у папок обычно поле file указывает на саму папку)
    if vim.fn.isdirectory(full_path) == 1 then
      dir_path = full_path
    else
      -- Если это файл, получаем путь к его родительской папке
      dir_path = vim.fn.fnamemodify(full_path, ":p:h")
    end

    -- Сохраняем результат
    _G.my_saved_dir = dir_path

    -- Уведомляем пользователя
    Snacks.notify.info("Папка сохранена: " .. dir_path)

    return dir_path
  else
    Snacks.notify.error("Не удалось определить путь")
  end
end

return M
