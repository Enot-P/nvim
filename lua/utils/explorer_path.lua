local M = {}

local function process_directory(dir_path)
  local dir_name = vim.fn.fnamemodify(dir_path, ":t")
  local target_file_name = dir_name .. ".dart"
  local exports = {}
  local entries = vim.fn.readdir(dir_path)

  for _, entry in ipairs(entries) do
    local full_entry_path = dir_path .. "/" .. entry
    if vim.fn.isdirectory(full_entry_path) == 1 then
      local subdir_barrel = process_directory(full_entry_path)
      if subdir_barrel then
        table.insert(exports, string.format("export '%s/%s';", entry, subdir_barrel))
      end
    elseif entry:match("%.dart$") and entry ~= target_file_name then
      table.insert(exports, string.format("export '%s';", entry))
    end
  end

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

-- Внутренняя функция рефакторинга (без shell и sed)
local function refactor_in_neovim(dir_name, main_barrel, rg_pattern)
  local cmd = string.format("rg -l %s --type dart", vim.fn.shellescape(rg_pattern))
  local files = vim.fn.systemlist(cmd)

  if vim.v.shell_error ~= 0 or #files == 0 then
    return 0
  end

  -- Регулярка для Lua: ищет импорт, содержащий папку, и меняет остаток пути на барел
  local search_lua = "import (['\"].*/" .. dir_name .. "/).-%.dart(['\"];)"
  local replace_lua = "import %1" .. main_barrel .. "%2"

  local changed_count = 0
  for _, file_path in ipairs(files) do
    local f = io.open(file_path, "r")
    if f then
      local content = f:read("*all")
      f:close()

      local new_content, count = content:gsub(search_lua, replace_lua)

      if count > 0 then
        local wf = io.open(file_path, "w")
        if wf then
          wf:write(new_content)
          wf:close()
          changed_count = changed_count + 1
        end
      end
    end
  end
  return changed_count
end

M.generate_exports = function(picker)
  local item = picker:current()
  if not (item and item.file) then
    Snacks.notify.error("Не удалось определить путь")
    return
  end

  local start_path = vim.fn.isdirectory(item.file) == 1 and item.file or vim.fn.fnamemodify(item.file, ":p:h")
  local dir_name = vim.fn.fnamemodify(start_path, ":t")

  -- Генерация экспортов
  local main_barrel = process_directory(start_path)

  if main_barrel then
    -- Рефакторинг импортов во всем проекте
    local rg_pattern = "import ['\"].*/" .. dir_name .. "/.*\\.dart['\"];"
    Snacks.notify.info("Рефакторинг импортов для: " .. dir_name)

    local count = refactor_in_neovim(dir_name, main_barrel, rg_pattern)

    vim.schedule(function()
      Snacks.notify.info(string.format("Барел создан. Рефакторинг: %d файлов.", count))
    end)
  else
    Snacks.notify.warn("В папке " .. dir_name .. " нет dart-файлов")
  end
end

return M
