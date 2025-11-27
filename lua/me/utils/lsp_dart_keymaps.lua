local M = {}

function M.on_attach(client, bufnr)
  local telescope_builtin = require("telescope.builtin")
  local function filtered_code_actions()
    vim.lsp.buf.code_action({
      apply = false,
      filter = function(action)
        if not action or not action.title then
          return true
        end
        -- Для импортов скрываем только относительные пути ('./' или '../')
        if action.title:match("^Import library") then
          if action.title:match("%./") or action.title:match("%.%./") then
            return false
          end
          return true
        end
        return true
      end,
    })
  end
  vim.keymap.set('n', 'gd', telescope_builtin.lsp_definitions,
    { buffer = bufnr, desc = "Перейти к определению (Telescope)" })
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, { buffer = bufnr, desc = "Показать документацию" })
  vim.keymap.set('n', 'gi', telescope_builtin.lsp_implementations,
    { buffer = bufnr, desc = "Перейти к реализации (Telescope)" })
  vim.keymap.set('n', '<leader>r', vim.lsp.buf.rename, { buffer = bufnr, desc = "Переименовать" })
  vim.keymap.set('n', 'ca', filtered_code_actions, { buffer = bufnr, desc = "Действия с кодом (фильтр импортов)" })
  vim.keymap.set('n', 'gr', telescope_builtin.lsp_references,
    { buffer = bufnr, desc = "Показать использования (Telescope)" })
end


function M.on_attach_flutter(client, bufnr)
  local flutter_tools = require("flutter-tools")
  local telescope_builtin = require("telescope.builtin")

  -- Используем общие кеймапы
  M.on_attach(client, bufnr)

  -- Специфичные для Flutter
  vim.keymap.set('n', '<leader>fR', flutter_tools.reload, { buffer = bufnr, desc = "Flutter: Hot Reload" })
  vim.keymap.set('n', '<leader>fr', flutter_tools.restart, { buffer = bufnr, desc = "Flutter: Hot Restart" })
  vim.keymap.set('n', '<leader>fq', flutter_tools.quit, { buffer = bufnr, desc = "Flutter: Quit App" })
  vim.keymap.set('n', '<leader>fd', flutter_tools.devices, { buffer = bufnr, desc = "Flutter: Выбрать устройство" })
  vim.keymap.set('n', '<leader>fD', flutter_tools.dev_log, { buffer = bufnr, desc = "Flutter: Открыть Dev Log" })
  vim.keymap.set('n', '<leader>fe', flutter_tools.emulators, { buffer = bufnr, desc = "Flutter: Выбрать эмулятор" })

  -- Кеймапы для виджетов
  vim.keymap.set('n', '<leader>fwc', flutter_tools.wrap_widget, { buffer = bufnr, desc = "Flutter: Обернуть виджет" })
  vim.keymap.set('n', '<leader>fwr', flutter_tools.remove_widget, { buffer = bufnr, desc = "Flutter: Удалить виджет" })
  vim.keymap.set('n', '<leader>fws', flutter_tools.split_widget, { buffer = bufnr, desc = "Flutter: Разделить виджет" })

  -- Telescope для Flutter
  vim.keymap.set('n', '<leader>fv', flutter_tools.visual_debug, { buffer = bufnr, desc = "Flutter: Визуальный дебаг" })
end

return M
