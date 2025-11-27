local M = {}

-- Рекурсивная функция для генерации экспортов в папке и всех подпапках
function M.generate_exports_recursive(dir_path)
  -- Получаем название папки
  local dir_name = vim.fn.fnamemodify(dir_path, ":t")
  local export_file_name = dir_name .. ".dart"
  local export_file_path = dir_path .. "/" .. export_file_name

  local files_to_export = {}
  local subdirs_with_exports = {}

  -- Сканируем содержимое папки
  local handle = vim.loop.fs_scandir(dir_path)
  if not handle then
    vim.notify("Could not open directory: " .. dir_path, vim.log.levels.ERROR)
    return false
  end

  -- Собираем файлы и подпапки
  local dart_files = {}
  local subdirectories = {}

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end

    if type == 'file' and name:match("%.dart$") and not name:match("%.g%.dart$") and name ~= export_file_name then
      table.insert(dart_files, name)
    elseif type == 'directory' and not name:match("^%.") then -- игнорируем скрытые папки
      table.insert(subdirectories, name)
    end
  end

  -- Рекурсивно обрабатываем подпапки
  for _, subdir in ipairs(subdirectories) do
    local subdir_path = dir_path .. "/" .. subdir
    local success = M.generate_exports_recursive(subdir_path)
    if success then
      -- Добавляем ссылку на экспортный файл подпапки
      table.insert(subdirs_with_exports, "export '" .. subdir .. "/" .. subdir .. ".dart';")
    end
  end

  -- Добавляем экспорты для .dart файлов в текущей папке
  for _, file in ipairs(dart_files) do
    table.insert(files_to_export, "export '" .. file .. "';")
  end

  -- Добавляем экспорты подпапок
  for _, export_line in ipairs(subdirs_with_exports) do
    table.insert(files_to_export, export_line)
  end

  -- Создаем экспортный файл, если есть что экспортировать
  if #files_to_export > 0 then
    local file_content = table.concat(files_to_export, "\n") .. "\n"
    local file = io.open(export_file_path, "w")
    if file then
      file:write(file_content)
      file:close()
      vim.notify("Generated " .. export_file_name .. " in " .. dir_path, vim.log.levels.INFO)
      return true
    else
      vim.notify("Error creating " .. export_file_name .. " in " .. dir_path, vim.log.levels.ERROR)
      return false
    end
  else
    vim.notify("No .dart files to export in " .. dir_path, vim.log.levels.WARN)
    return false
  end
end

-- Основная функция, вызываемая пользователем
function M.generate_exports()
  local current_dir = vim.fn.expand('%:p:h')
  if current_dir == "" then
    vim.notify("Could not get current directory.", vim.log.levels.WARN)
    return
  end

  M.generate_exports_recursive(current_dir)
end

-- Функция для генерации только в текущей папке (старое поведение)
function M.generate_exports_current_only()
  local current_dir = vim.fn.expand('%:p:h')
  if current_dir == "" then
    vim.notify("Could not get current directory.", vim.log.levels.WARN)
    return
  end

  local dir_name = vim.fn.fnamemodify(current_dir, ":t")
  local export_file_name = dir_name .. ".dart"
  local export_file_path = current_dir .. "/" .. export_file_name
  local files_to_export = {}

  local handle = vim.loop.fs_scandir(current_dir)
  if not handle then
    vim.notify("Could not open directory: " .. current_dir, vim.log.levels.ERROR)
    return
  end

  while true do
    local name, type = vim.loop.fs_scandir_next(handle)
    if not name then
      break
    end
    if type == 'file' and name:match("%.dart$") and not name:match("%.g%.dart$") and name ~= export_file_name then
      table.insert(files_to_export, "export '" .. name .. "';")
    end
  end

  if #files_to_export > 0 then
    local file_content = table.concat(files_to_export, "\n") .. "\n"
    local file = io.open(export_file_path, "w")
    if file then
      file:write(file_content)
      file:close()
      vim.notify("Generated " .. export_file_name, vim.log.levels.INFO)
    else
      vim.notify("Error creating " .. export_file_name, vim.log.levels.ERROR)
    end
  else
    vim.notify("No .dart files to export in " .. current_dir, vim.log.levels.WARN)
  end
end

return M
