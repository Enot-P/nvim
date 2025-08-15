local M = {}

function M.generate_exports()
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

    if type == 'file' and name:match("%.dart$") and not name:match("%.g.dart$") and name ~= export_file_name then
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
