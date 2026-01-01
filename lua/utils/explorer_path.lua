local M = {}

M.save_path_from_picker = function(picker)
  local item = picker:current()
  if item and item.file then
    local my_path = item.file
    -- Используем notify, так как print иногда перехватывается пикером
    vim.notify("Путь получен: " .. my_path)
    return my_path
  end
end

return M
