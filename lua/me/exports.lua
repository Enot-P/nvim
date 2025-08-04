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

function M.send_to_tmux_window(window_id, command)
  -- Проверка, что аргументы переданы
  if not window_id or not command then
    vim.notify("Error: window_id and command must be provided", vim.log.levels.ERROR)
    return
  end

  -- Проверка, что Neovim работает в tmux
  if vim.fn.exists('$TMUX') == 0 then
    vim.notify("Error: Neovim is not running inside a tmux session", vim.log.levels.ERROR)
    return
  end

  -- Экранирование команды
  local escaped_command = command:gsub("'", "'\\''")
  local tmux_cmd = string.format("tmux send-keys -t %s '%s' C-m", window_id, escaped_command)

  -- Выполнение команды и проверка результата
  local output = vim.fn.system(tmux_cmd)
  if vim.v.shell_error == 0 then
    vim.notify("Command sent to tmux window " .. window_id .. ": " .. command, vim.log.levels.INFO)
  else
    vim.notify("Error sending command to tmux window " .. window_id .. ": " .. (output or "Unknown error"), vim.log.levels.ERROR)
  end
end

-- Определение пользовательской команды с улучшенной обработкой аргументов
vim.api.nvim_create_user_command('SendToTmux', function(opts)
  -- Разделяем аргументы по пробелу
  local args = vim.split(opts.args, "%s+", { trimempty = true })
  if #args < 2 then
    vim.notify("Error: Usage: SendToTmux <window_id> <command>", vim.log.levels.ERROR)
    return
  end

  local window_id = args[1]
  local command = table.concat({ unpack(args, 2) }, " ") -- Собираем оставшиеся аргументы в команду
  M.send_to_tmux_window(window_id, command)
end, { nargs = '+' })

return M
