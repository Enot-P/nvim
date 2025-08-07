local M = {}

function M.generate_exports()
  local current_buf_path = vim.api.nvim_buf_get_name(0)
  local current_dir = vim.fn.fnamemodify(current_buf_path, ":h")
  local dir_name = vim.fn.fnamemodify(current_dir, ":t")
  local export_file_name = dir_name .. ".dart"
  local export_file_path = current_dir .. "/" .. export_file_name
  local files_to_export = {}

  for _, file in ipairs(vim.fn.readdir(current_dir)) do
    if file:match("%.dart$") and file ~= export_file_name then
      table.insert(files_to_export, "export '" .. file .. "';")
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


vim.keymap.set("n", "<leader>ge", function()
  require("me.exports").generate_exports()
end, { desc = "Сгенерировать экспортный файл" })

return M
